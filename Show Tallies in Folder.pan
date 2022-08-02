global thisFolder,allFiles,theTallies
local loopcount
thisFolder=folder("")
allFiles=listfiles(thisFolder,"????KASX")
theTallies=""
loopcount=1
loop
if (array(allFiles,loopcount,¶) contains "45" or array(allFiles,loopcount,¶) contains "44") 
and (array(allFiles,loopcount,¶) contains "walk" or array(allFiles,loopcount,¶) contains "tall")
and (array(allFiles,loopcount,¶) notcontains "recon")
theTallies=theTallies+¶+array(allFiles,loopcount,¶)
endif
increment loopcount
until loopcount>arraysize(allFiles,¶)
arraystrip theTallies,¶
displaydata theTallies