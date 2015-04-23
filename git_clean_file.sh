
big_name=$1;
#echo "file: $big_name";

if [ -z $big_name ]; then
	echo "syntax: $0 <file to remove>";
	exit 1;
fi

echo "find commits ...";
git log --pretty=oneline --branches -- $big_name

read -p "File will be removed from all listed commits. Continue? [Y/n] " -n 1 yn
echo ""

if [ -z $yn ]; then
	yn='y';
fi

if [[ ! $yn =~ ^[Yy]$ ]]; then
	exit 1
fi 

echo "";
first_commit=$(git log --pretty=oneline --branches -- $big_name | tail -n 1 | cut -d ' ' -f 1);
echo "olest commit is $first_commit";
if [ ! -z $first_commit ]; then
	rm_cmd="git rm --ignore-unmatch --cached -- $big_name"
echo "rm cmd: $rm_cmd";
	git filter-branch --index-filter "$rm_cmd" -- $first_commit^..
fi

echo "clear refs...";
rm -rf .git/refs/original
rm -rf .git/logs/
git reflog expire --all --expire='0 days'
git fsck --full --unreachable

echo "repack..."
git repack -A -d
git prune

