#! /bin/bash
# TODO 判断convert命令是否存在
function usage
{
  echo '----------------------'
  echo '    Image process     '
  echo '----------------------'
  echo 'USAGE:'
  echo 'Option :'
  echo '    -h , help'
  echo '    -r , recursion processing of all supported image files in the specified directory'
  echo '    -qc, quality compression of jpeg images'
  echo '    -rc, compression resolution of images while maintaining the original aspect ratio (allow jpeg/png/svg)'
  echo '    -w , adding custom text watermarks to images'
  echo '    -p , add filename prefix'
  echo '    -s , add filename suffix'
  echo '    -c , convert png/svg images to jpeg images'
}

# 图片质量压缩
function compressionQua
{
  file=$1
  ratio=$2
  $(convert -quality $ratio $file $file )
  echo "* quality compression with ratio = $ratio"
}

# 压缩分辨率
function compressionRes
{
  file=$1
  resolution=$2
  $(convert -resize $resolution $file $file )
  echo "* compression to resolution = $resolution"
}

# 添加文本水印
function addWM
{
  file=$1
  wm=$2
  $(convert $file -gravity southeast -font 1.ttf -fill white -pointsize 64 -draw 'text 5,5 '\'$wm\' $file)
  echo "* add watermark $wm"
}

# 添加文件名前缀
function addPrefix
{
  old=$1
  dir=$(dirname $1)
  file=$(basename $1)
  pre=$2
  filename="${file%.*}"
  ext="${file##*.}"
  new=$dir'/'$pre$filename'.'$ext
  $(mv $old $new)
  $input=$new
  echo "* change file name from $old to $new"
}

# 添加文件名后缀
function addSuffix
{
  old=$1
  dir=$(dirname $1)
  file=$(basename $1)
  suf=$2
  filename="${file%.*}"
  ext="${file##*.}"
  new=$dir'/'$filename$suf'.'$ext
  $(mv $old $new)
  $input=$new
  echo "* change file name from $old to $new "
}

# 将png/svg转换为jpg
function convertFmt
{
  file=$1
  filename="${file%.*}"
  ext="${file##*.}"
  jpgfile=$filename'.jpg'

  if [[ $ext = 'jpg' ]]
  then
    echo 'Warn: input file is already a jpg file'
  elif [[ $ext != 'png' && $ext != 'svg' ]]
  then
    echo 'Warn: input file is neither a svg nor a png file'
  else
    $(convert $file $jpgfile)
    echo "* change file format from $file to $jpgfile "
  fi
}

# 处理文件夹下所有文件
function batch
{
  dir=$1
  fmt=('jpeg' 'png' 'svg')
  for file in $(ls $dir)
  do
    filepath=$dir'/'$file
    echo -e "\n----  Peocessing $filepath ----"
    subProcess $filepath 
  done
  echo 'Batch Finished'
}
#echo $0 
#echo $1
#echo $2
#echo $* 
#echo $@

function subProcess
{
  input=$1 
  if [[ $flag_h = 1 ]]
  then 
    usage
  fi 

  if [[ $flag_qc = 1 && $input && $compRatio ]]
  then 
    compressionQua $input $compRatio
  fi

  if [[ $flag_rc = 1 && $input && $resolution ]]
  then
    compressionRes $input $resolution
  fi

  if [[ $flag_w = 1 && $input && $watermark ]]
  then
    addWM $input $watermark
  fi

  if [[ $flag_c = 1 ]]
  then
    convertFmt $input
  fi
 
  if [[ $flag_p = 1 && $prefix ]]
  then 
    addPrefix $input $prefix
  fi

  if [[ $flag_s = 1 && $suffix ]]
  then
    addSuffix $input $suffix
  fi

}

function mainProcess
{
  input=$1
  if [[ $flag_r = 1 && $directory ]]
  then 
    batch $directory
  else
    subProcess $input
  fi
}


flag_h=0;
flag_i=0;
flag_o=0;
flag_r=0;
flag_qc=0;
flag_rc=0;
flag_w=0;
flag_p=0;
flag_s=0;
flag_c=0;

# 获取参数值
while [ -n "$1" ]
do
  case "$1" in 
    -h)
      flag_h=1
      #echo "------------------  -h choosed"
      ;;  
    -i)
      flag_i=1
      input=$2
      shift
      #echo "------------------  -i choosed"
      ;;
    -o)
      flag_o=1
      output=$2
      shift
      #echo "------------------  -o choosed"
      ;;
    -r)
      flag_r=1
      directory="$2"
      shift
      #echo "------------------  -r choosed"
      ;;
    -qc)
      flag_qc=1
      compRatio=$2
      shift
      #echo "------------------  -qc choosed"
      ;;
    -rc)
      flag_rc=1
      resolution=$2
      shift
      #echo "------------------  -rc choosed"
      ;;
    -w) 
      flag_w=1
      watermark=$2 
      shift
      #echo "------------------  -w choosed"
      ;;
    -p)
      flag_p=1
      prefix=$2
      shift
      #echo "------------------  -p choosed"
      ;;
    -s)
      flag_s=1
      suffix=$2
      shift
      #echo "------------------  -s choosed"
      ;;
    -c)
      flag_c=1
      shift
      #echo "------------------  -c choosed"
      ;;
    *)
     #echo "$1 is not an option";
      ;;
  esac
  shift
done

mainProcess $input

echo "process exit with status:$?"
