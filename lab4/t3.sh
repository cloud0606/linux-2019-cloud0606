#! usr/bin/env bash
function usage
{
  echo '-------------------------------------------'
  echo '-- 本脚本用于统计 web_log.tsv 中以下数据 --'
  echo '-------------------------------------------'
  echo '-h 输出帮助文档'
  echo '-s 统计访问来源主机TOP 100和分别对应出现的总次数'
  echo '-sp 统计访问来源主机TOP 100 IP和分别对应出现的总次数'
  echo '-d 统计最频繁被访问的URL TOP 100'
  echo '-c 统计不同响应状态码的出现次数和对应百分比'
  echo '-cu 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数'
  echo '-u 指定url,给定URL输出TOP 100访问来源主机 -u'
} 

#echo "$(awk -F '\t' '{print $1}' web_log.tsv | sort | uniq -c | sort -rn | head -n 10)"
#echo "$(awk -F '\t' --re-interval '{if($1~/^(([0-2]*[0-9]*[0-9]*).([0-2]*[0-9]*[0-9]*).([0-2]*[0-9]*[0-9]*).([0-2]*[0-9]*[0-9]*))$/) print $1}' web_log.tsv | sort | uniq -c | sort -rn | head -n 10)"


while [[ -n "$1" ]]
do 
  case "$1" in 
    -h)
      usage
      ;;
    -s)
      echo '* 统计访问来源主机TOP 100和分别对应出现的总次数:'
      echo "$(awk -F '\t' '{print $1}' web_log.tsv | sort | uniq -c | sort -rn | head -n 100)"
      ;;
    -sp)
      echo '* 统计访问来源主机TOP 100 IP和分别对应出现的总次数'
      echo "$(awk -F '\t' --re-interval '{if($1~/^(([0-2]*[0-9]*[0-9]*).([0-2]*[0-9]*[0-9]*).([0-2]*[0-9]*[0-9]*).([0-2]*[0-9]*[0-9]*))$/) print $1}' web_log.tsv | sort | uniq -c | sort -rn | head -n 100)"
      ;;
    -d)
      echo '* 统计最频繁被访问的URL TOP 100'
      echo "$(awk -F '\t' '{print $5}' web_log.tsv | sort | uniq -c | sort -rn | head -n 100)"
      ;;
    -c)
      echo '* 统计不同响应状态码的出现次数和对应百分比'
      echo "$(awk  -F '\t' 'NR>1 { response[$6]++;} END{ for(k in response){ p=100*response[k]/(NR-1); printf("%s\t%.6f%%\t",k,p); print response[k]"\t";} }' web_log.tsv)"
      ;;
    -cu)
      echo '* 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数'
      echo "$(sed -e '1d' web_log.tsv | awk -F '\t' ' {if($6~/^403/) {a[$6" : "$5]++}} END {for(i in a){print i,a[i] }}' | sort -nr -k2 | head -n 10)"
      echo "$(sed -e '1d' web_log.tsv | awk -F '\t' ' {if($6~/^404/) {a[$6" : "$5]++}} END {for(i in a){print i,a[i] }}' | sort -nr -k2 | head -n 10)"
      ;;
    -u)
      url=$2
      shift
      echo '* 指定url,给定URL输出TOP 100访问来源主机 -u'
      echo "$(sed -e '1d' web_log.tsv|awk -F '\t' '{if($5=="'$url'") a[$1]++} END {for(i in a){print i,a[i]}}'|sort -nr -k2|head -n 100)"
      ;;
  esac
  shift
done


