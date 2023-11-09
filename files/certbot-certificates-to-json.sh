#!/usr/bin/awk -f
# 
# CERTS=$(certbot certificates)
# echo "${CERTS}" | awk '

function trim(str) {
    gsub(/^[ \t]+|[ \t]+$/, "", str)
    return gensub(" ", "_", "g", tolower(str))
}

function join(array, start, end, sep,    result, i)
{
    if (sep == "")
       sep = " "
    else if (sep == SUBSEP) # magic value
       sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
        gsub(/^[ \t]+|[ \t]+$/, "", result)
    return result
}

BEGIN {
    RS="  Certificate Name: ";
    FS="\n";
    OFS=",";
    ORS="\n";
    print "{"
} {
    if ($1 != "") {
        j=1
        if (FNR >= 3) print ","
        printf "\""$1"\":{"
        for (i=2; i<=NF; i++) {
            n=split($i, kv, ":")
            if (kv[1] == "") {continue; } 
            if (kv[1] ~ /- -/) { continue; }
            if (kv[1] ~ /Domains$/) {
                m=split(kv[2], doms, " ")
                value="[\"" join(doms, 1, m, "\",\"") "\"]"
                dict[j]="\"" trim(kv[1]) "\": " value ""
            } else {
                value=join(kv, 2, n, ":")
                dict[j]="\"" trim(kv[1]) "\": \"" value "\""
            }
            j=j+1
        }
        print join(dict, 1, j-1, ",")
        printf "}"
    }
} 
END { 
    print "}"
}
