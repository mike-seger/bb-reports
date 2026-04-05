#!/bin/bash

reportsdir=${1:-.}
if [ ! -d "$reportsdir" ] ; then
	echo "Usage: $0 <reportsdir>"
	echo "<reportsdir> must contain report directories with a stats.txt in each"
	exit 1
fi

categories=$(find "$reportsdir" -name stats.txt -print0 | \
  xargs -0 grep -h SUCCESS | \
  sed -e "s/run_//;s/^[^_]*_//;s/_.*.txt://;s/ SUCCESS : /\t/;s/ *s *$//" | \
  cut -f1 | awk '!seen[$0]++')

showtitle=1
for f in $(find "$reportsdir" -name stats.txt); do
	tim=$(cat $f | grep SUCCESS |\
		sed -e "s/run_//;s/^[^_]*_//;
			s/_.*.txt://;s/ SUCCESS : /\t/;s/ *s *$//")
printf "%s - %s\n" "$f" "$tim" >&2
	if [ $showtitle == 1 ] ; then
		echo -n "system"
		for c in $(echo $categories); do
			printf "\t%s" "$c"
		done
		printf "\ttotal\n"
		showtitle=0
	fi
	printf "%-32s" $(echo -n "$f" | sed -e "s#/stats.txt##;s#.*/##")
	total=0
	for c in $(echo $categories); do
		n=$(printf "%s" "$tim" | awk -v c="$c" '$1 == c { print $2 }' | \
			sort -n | head -3 | \
			awk '{ sum += $1; n++ } END { if (n > 0) print int(sum / n + 0.5); else print 0; }')
		total=$((total+n))
		printf "\t%s" "$n"
		#cut -f2|sort -n|head -3 
	done
	printf "\t$total\n"
#	sed -e "s/run_//;s/^[^_]*_//;s/_.*.txt://"
	
done | (read -r; printf "%s\n" "$REPLY"; sort -nk6) 
