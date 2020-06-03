#！/bin/bash

#模板名称
templateName="SampleModule"


ProjectName=$1
ModuleName=$2
useLocalSample=$3

echo "Cleaning up old folder..."
rm -rf $templateName
rm -rf $ProjectName$ModuleName

if [[ "$ProjectName"x == "x" ]]; then
	echo "Incorrect ProjectName!!!"
	exit
fi

if [[ "$ModuleName"x == "x" ]]; then
	echo "Incorrect ModuleName!!!"
	exit
fi

if [ "$useLocalSample" == "1" ]; then
 	cp -R ../samplemodule samplemodule
else
	wifiName=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep "SSID: PA_WLAN" | sed 's/SSID://g' | sed 's/^[ \t]*//g'`
	echo $wifiName
	if [[ "$wifiName" != "PA_WLAN" ]]; then
		echo "this command shold be exec in PA_WLAN wifi"
		exit
	fi

	git clone "http://code.paic.com.cn/pasmartcity/samplemodule.git"
fi

cd ./$templateName

echo "Removing .git folder..."
rm -Rf ./$templateName/.git

 echo "replacing $templateName content in all files..."
 # sed -i "" "s/$ModuleName/g" `grep $templateName -rl "./$templateNameTests"`
 # sed -i "" "s/$ModuleName/g" `grep $templateName -rl "./$templateNameBundle"`
 # sed -i "" "s/$ModuleName/g" `grep $templateName -rl "./$templateName"`
 # sed -i "" "s/$ModuleName/g" `grep $templateName -rl "./$templateName.xcodeproj"`
 # sed -i "" "s/$templateName/g" `grep $templateName -rl ./$templateName.xcodeproj`
sed -i "" "s/$templateName/$ModuleName/g" `grep $templateName -rl ./${templateName}Tests`
sed -i "" "s/$templateName/$ModuleName/g" `grep $templateName -rl ./${templateName}`
sed -i "" "s/$templateName/$ModuleName/g" `grep $templateName -rl ./$templateName.xcworkspace/contents.xcworkspacedata`
sed -i "" "s/$templateName/$ModuleName/g" `grep $templateName -rl ./$templateName.xcodeproj`

mv "./$templateName.xcodeproj" "./$ProjectName$ModuleName.xcodeproj"


 echo ""
 echo "Renaming folders and files..."
 IFS=$'\n'

for ((i=0; i<1;))
do
	i=1
	for file in `find . -name "*$templateName*"`
	do
		i=0
		newFile=${file//$templateName/$ModuleName}
		mv "$file" "$newFile"
		echo "Renamed $file to $newFile"
		break
	done
done

mv "./../$templateName" "./../$ProjectName$ModuleName"

xcodebuild clean
rm -rf ./build
echo "Done! Now you have your $ProjectName $ModuleName project."

# add dependency
pwd
cd ..
ruby createProjectDependcy.rb $ProjectName$ModuleName


echo "Removing script files..."
cd ./$ProjectName$ModuleName
rm -Rf createModule.sh
rm -Rf createProjectDependcy.rb
