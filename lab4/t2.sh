#! /bin/bash
#$(wget https://github.com/cloud0606/LinuxSysAdmin/blob/master/exp/chap0x04/worldcupplayerinfo.tsv)
#cat worldcupplayerinfo.tsv | while read line
#do 
#  age=$(echo $line | awk '{print $6}')
#  name=$(echo $line | awk '{print $9}')
#  position=$(echo $line | awk '{print $5}')
# # echo $age $name $position 
#done
age=$(awk -F '\t' '{print $6}' worldcupplayerinfo.tsv)
nameLen=$(awk -F '\t' '{print length($9)}' worldcupplayerinfo.tsv)
position=$(awk -F '\t' '{print $5}' worldcupplayerinfo.tsv)

function nameLengthCal
{
  #nameLen=$(awk -F '\t' '{print length($9)}' worldcupplayerinfo.tsv)
  lenMax=0
  lenMin=100
  sum=9
  for nl in $nameLen
  do
    sum=$((sum+1))
    #echo "$nl"
    if [[ $nl -gt $lenMax ]]
    then
      lenMax=$((nl))
    fi 
    if [[ $nl -lt $lenMin ]]
    then 
      lenMin=$((nl))
    fi
  done
  #echo "sum：$sum"
  echo ''
  echo "名字最长的球员是：$(awk -F '\t' '{if(length($9)=='$lenMax'){ print $9 } }' worldcupplayerinfo.tsv)"
  echo "名字最短的球员是：$(awk -F '\t' '{if(length($9)=='$lenMin'){ print $9 } }' worldcupplayerinfo.tsv)"
}

function positionCal
{
  sum=0
  declare -A posDic
  for pos in $position
  do
   #echo $pos  
    if [[ $pos != 'Position' ]]
    then
      sum=$((sum+1))
      if [[ -n ${posDic[$pos]} ]]
      then  
        posDic[$pos]=$(( ${posDic[$pos]} +1 ))
      else
        posDic[$pos]=1
      fi
    fi
  done

  echo ''
  echo "场上不同的位置、对应球员数量百分比如下:"
  for pos in "${!posDic[@]}"
  do
    posNum=${posDic[$pos]}
    echo "$pos : $posNum 占比=$(echo "scale=5;$posNum/$sum*100 "| bc )%"
  done
}

function ageCount
{
  L20=0
  Bet2030=0
  G30=0
  sum=0

  ageMax=0
  ageMin=100

  for a in $age
  do
    if [[ $a != 'Age' ]]
    then
      sum=$((sum + 1))  
      if [[ $a -lt 20 ]]
      then 
        L20=$((L20 + 1))
      elif [[ $a -le 30 ]]
      then 
        Bet2030=$((Bet2030 + 1))
      else
        G30=$((G30 + 1))
      fi

      if [[ $a -gt $ageMax ]]
      then 
        ageMax=$(( a ))
      fi

      if [[ $a -lt $ageMin ]]
      then 
        ageMin=$(( a ))
      fi

   fi
  done

  oldest=$(awk -F '\t' '{if ($6~/'$ageMax'/) {print $9} }' worldcupplayerinfo.tsv)
  youngest=$(awk -F '\t' '{if ($6~/'$ageMin'/) {print $9} }' worldcupplayerinfo.tsv)

  echo "统计信息有: $sum"
  echo ''
  echo "小于20岁的人有: $L20 占比：$(echo "scale=5;$L20/$sum*100"| bc ) %"
  echo " 20~30岁的人有：$Bet2030 占比：$(echo "scale=5;$Bet2030/$sum*100"| bc ) %"
  echo "大于30岁的人有: $G30 占比：$(echo "scale=5;$G30/$sum*100"| bc ) %"

  echo "年龄最大的球员是：$oldest  年龄：$ageMax"
  echo "年龄最小的球员是：$youngest  年龄：$ageMin"
}

function usage 
{
  echo '------------------------------------------------------------'
  echo '--  本脚本用于统计 worldcupplayerinfo.tsv 文件中以下数据  --'
  echo '-------------------------------------------------------------'
  echo '统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比'
  echo '统计不同场上位置的球员数量、百分比'
  echo '名字最长的球员是谁？名字最短的球员是谁？'
  echo '年龄最大的球员是谁？年龄最小的球员是谁？'
  echo ''
}


if [[ -n "$1" &&( "$1"='-h' || "$1"='--help')]] 
then 
  usage
else
  ageCount
  positionCal
  nameLengthCal
fi
