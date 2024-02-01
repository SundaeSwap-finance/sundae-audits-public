ROOT="$(cd "$(dirname "$0")/" && pwd)"

mkdir -p ${ROOT}/outputs

# loop through all the files in the directory:
for file in ${ROOT}/**/*.typ
do
    filename=$(basename -- "${file}")
    directory=$(basename $(dirname -- "${file}"))
    filename="${filename%.*}"
    if [ "$directory" = "templates" ]; then
        continue
    fi
    # run the compiler
    typst compile --root ${ROOT} --format=pdf "$file" "${ROOT}/outputs/${directory}.pdf"
done