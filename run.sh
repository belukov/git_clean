
#params
bigest_cnt=5

echo "clean repo..";
git gc
echo "";

echo "get size..";
size=$(git count-objects -v | grep 'size-pack' | cut -d ' ' -f 2)
echo "repo size: $size KB";
echo "";

echo "find pack..";
pack=$(ls .git/objects/pack/pack-*.pack | cut -d ' ' -f 1);
echo "pack: $pack";
echo "";

echo "find biggest file..";

IFS=$'\n'
big_str_arr=( $(git verify-pack -v $pack | sort -k 3 -n | tail -${bigest_cnt} | sort -k 3 -n -r) );

for (( i=0; i<bigest_cnt; i++ ))
do 
	big_str=${big_str_arr[$i]};
	big_str=$(echo $big_str | sed 's/  */ /g');
	big_hash=$(echo $big_str | cut -d ' ' -f 1);
	big_hash_arr[$i]=$big_hash;

	big_size=$(echo $big_str | cut -d ' ' -f 3);
	big_size_arr[$i]=$big_size;
	big_name=$(git rev-list --objects --all | grep $big_hash | cut -d ' ' -f 2);
	big_name_arr[$i]=$big_name

	let num=i+1;
	echo "$num : $big_hash : $big_size B : $big_name";
done

read -p "Select the file (1 - $bigest_cnt) (0 - exit) : "   num
echo ""

if [[ ! $num =~ ^[0-9]+$ ]]; then
	num=0
fi

echo "num: $num";

if [ $num -eq 0 ] || [ $num -gt $bigest_cnt ]; then
	exit 0;
fi

let sel=num-1

echo "you choose $num : ${big_name_arr[$sel]} ...";
big_name="${big_name_arr[$sel]}"



script_dir=$(dirname $(readlink -f $0)  )


${script_dir}/git_clean_file.sh ${big_name}

echo "finish..";
