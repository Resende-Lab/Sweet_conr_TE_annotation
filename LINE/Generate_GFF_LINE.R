library(rtracklayer)
library(stringr)
library(data.table)
library(plyr)

GENOMENAME='Ia453' # Change Genome ID
SHORTID='Zm00045a' # Change MaizeGDB ID

######### Read in target/mtea results
## these match to mtec families
a=read.table('all_LINE.tab', header=F)
a$mtec=str_split_fixed(a$V1, "_", 3)[,2]
a$sup=str_split_fixed(a$V1, "_", 3)[,1]


## get rid of overlaps, arbitrarily picking the last if there are multiple ambiguous TSDs
## last due to the action of findOverlaps reporting

a.gr=GRanges(seqnames=a$V2, IRanges(start=a$V3, end=a$V4))
## note this is different than the helitron case, because we believe ONE of these TSD pairs is real, and there's a LINE here.
rmRows=unique(queryHits(findOverlaps(a.gr, drop.self=T, ignore.strand=T, drop.redundant=T)))

a=a[-rmRows,]



## there are NO NEW LINE FAMILIES
## but I do need to learn the 5 digit code I've assigned to each, based on copy number in B73
names=fread('grep RI /ufrc/settles/mullerbsf/4_Sweet_Corn_Genome/6_TARGeT/Detect_LINE/B73v4.TE.filtered.LINE.gff3')

names$ID=substr(names$V9,4,11)
names$mtec=str_split_fixed(names$V9, "_", 2)[,2]

maxFamNum=max(as.numeric(substr(names$ID, 4,8)))

a$b73fam=mapvalues(a$mtec, from=names$mtec, to=as.character(names$ID))
a$b73fam[!grepl('RI', a$b73fam)]=NA

a$NGenomemtec[is.na(a$b73fam)]=a$mtec[is.na(a$b73fam)]


## first for new genome LINE families  ## this is super slow!!
for (x in 1:length(table(a$NGenomemtec))){
  famNum=str_pad(maxFamNum + x , 5, pad='0') # we want to increment families
  famName=names(rev(sort(table(a$NGenomemtec))))[x]  ## and keep track of original families
  sup=a$sup[a$NGenomemtec==famName & !is.na(a$NGenomemtec)][1]
  a$NGenomefam[a$NGenomemtec==famName & !is.na(a$NGenomemtec)]=paste(sup, famNum, SHORTID, str_pad(1:sum(a$NGenomemtec[!is.na(a$NGenomemtec)]==famName), 5, pad='0'), sep='')
}              


## assign 11 digit copy name (SHORTIDXXXXX) for each copy in an existing B73 family
a$Name=NA
for (x in names(table(a$b73fam))){
  a$Name[a$b73fam==x & !is.na(a$b73fam)]=paste(x, SHORTID, str_pad(1:sum(a$b73fam[!is.na(a$b73fam)]==x), 5, pad='0'), sep='')
}
a$Name[is.na(a$b73fam)]=a$NGenomefam[is.na(a$b73fam)]                   

## done!!!!
sum(is.na(a$Name))
                                
## output the gff

line.gff=data.frame(a$V2, 'TARGeT', 'LINE', a$V3, a$V4, '.', '*', '.', paste('ID=', a$Name, sep=''))
write.table(line.gff, paste(GENOMENAME, '.LINE.gff3', sep=''), quote=F, sep='\t', row.names=F, col.names=F)

### also keep track of fasta names and newly assigned gffnames as to easily convert between the two (e.g. switching fasta names)
write.table(data.frame(a$Name, a$sup, a$mtec), paste(GENOMENAME, '.LINE.gffname.fastaname.txt', sep=''), quote=F, sep='\t', row.names=F, col.names=F)
##########################################################################################
