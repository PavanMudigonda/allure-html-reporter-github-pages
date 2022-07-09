#! /usr/bin/env bash

          cat > index-template.html <<EOF

<!DOCTYPE html>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
 <title>Test Results</title>
 <style type="text/css">
  BODY { font-family : monospace, sans-serif;  color: black;}
  P { font-family : monospace, sans-serif; color: black; margin:0px; padding: 0px;}
  A:visited { text-decoration : none; margin : 0px; padding : 0px;}
  A:link    { text-decoration : none; margin : 0px; padding : 0px;}
  A:hover   { text-decoration: underline; background-color : yellow; margin : 0px; padding : 0px;}
  A:active  { margin : 0px; padding : 0px;}
  .VERSION { font-size: small; font-family : arial, sans-serif; }
  .NORM  { color: black;  }
  .FIFO  { color: purple; }
  .CHAR  { color: yellow; }
  .DIR   { color: blue;   }
  .BLOCK { color: yellow; }
  .LINK  { color: aqua;   }
  .SOCK  { color: fuchsia;}
  .EXEC  { color: green;  }
 </style>
</head>
<body>
	<h1>Test Results</h1><p>
	<a href=".">.</a><br>

EOF

unset JAVA_HOME
export TZ="/usr/share/zoneinfo/America/Toronto";
DATE_WITH_TIME=`date "+%Y-%m-%d %H:%M:%S %Z"`;
mkdir -p ./${INPUT_GH_PAGES}
mkdir -p ./${INPUT_ALLURE_HISTORY}
cp -r ./${INPUT_GH_PAGES}/. ./${INPUT_ALLURE_HISTORY}

REPOSITORY_OWNER_SLASH_NAME=${INPUT_GITHUB_REPO}
REPOSITORY_NAME=${REPOSITORY_OWNER_SLASH_NAME##*/}
GITHUB_PAGES_WEBSITE_URL="https://${INPUT_GITHUB_REPO_OWNER}.github.io/${REPOSITORY_NAME}"
#echo "Github pages url $GITHUB_PAGES_WEBSITE_URL"

if [[ ${INPUT_SUBFOLDER} != '' ]]; then
    INPUT_ALLURE_HISTORY="${INPUT_ALLURE_HISTORY}/${INPUT_SUBFOLDER}"
    INPUT_GH_PAGES="${INPUT_GH_PAGES}/${INPUT_SUBFOLDER}"
    echo "NEW allure history folder ${INPUT_ALLURE_HISTORY}"
    mkdir -p ./${INPUT_ALLURE_HISTORY}
    GITHUB_PAGES_WEBSITE_URL="${GITHUB_PAGES_WEBSITE_URL}/${INPUT_SUBFOLDER}"
    echo "NEW github pages url ${GITHUB_PAGES_WEBSITE_URL}"
fi

if [[ ${INPUT_REPORT_URL} != '' ]]; then
    GITHUB_PAGES_WEBSITE_URL="${INPUT_REPORT_URL}"
    echo "Replacing github pages url with user input. NEW url ${GITHUB_PAGES_WEBSITE_URL}"
fi

COUNT=$( ( ls ./${INPUT_ALLURE_HISTORY} | wc -l ) )
echo "count folders in allure-history: ${COUNT}"
echo "keep reports count ${INPUT_KEEP_REPORTS}"
INPUT_KEEP_REPORTS=$((INPUT_KEEP_REPORTS+1))
echo "if ${COUNT} > ${INPUT_KEEP_REPORTS}"
if (( COUNT > INPUT_KEEP_REPORTS )); then
  cd ./${INPUT_ALLURE_HISTORY}
  echo "remove index.html last-history"
  rm index.html last-history -rv
  echo "remove old reports"
  ls | sort -n | head -n -$((${INPUT_KEEP_REPORTS}-2)) | xargs rm -rv;
  cd ${GITHUB_WORKSPACE}
fi

cat index-template.html > ./${INPUT_ALLURE_HISTORY}/index.html

echo "├── <a href="./${INPUT_GITHUB_RUN_NUM}/index.html">RUN ID: ${INPUT_GITHUB_RUN_NUM} - ${DATE_WITH_TIME}(Latest)</a><br>" >> ./${INPUT_ALLURE_HISTORY}/index.html;
ls -l ./${INPUT_ALLURE_HISTORY} | grep "^d" | sort -nr | awk -F' ' '{print $9;}' | sed 's/last-history//' | while read line;
    do	    
	curl \
	   --silent \
	   --location \
	   --request GET \
	   --header 'Accept: application/vnd.github.v4+json' \
	   --header 'Content-Type: application/json' \
	   --header "Authorization: token ${INPUT_TOKEN}" \
	   --header 'cache-control: no-cache' \
	   "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/workflows/${INPUT_WORKFLOW_ID}/runs" > temp.json;
	   
	CREATED_AT=$(cat temp.json | jq --argjson "RUN_NUM" "${line}" -r '.workflow_runs[] | select(.run_number==$RUN_NUM) | .created_at');
	NEW_CREATED_AT=`sed -e 's/T/ /' -e 's/Z/ UTC/' <<<"$CREATED_AT"`
	echo "├── <a href="./"${line}"/">RUN ID: "${line}" -  "${NEW_CREATED_AT}" </a><br>" >> ./${INPUT_ALLURE_HISTORY}/index.html;
    done;
echo "</html>" >> ./${INPUT_ALLURE_HISTORY}/index.html;
# cat ./${INPUT_PLAYWRIGHT_HISTORY}/index.html

#echo "executor.json"
echo '{"name":"GitHub Actions","type":"github","reportName":"Allure Report with history",' > executor.json
echo "\"url\":\"${GITHUB_PAGES_WEBSITE_URL}\"," >> executor.json # ???
echo "\"reportUrl\":\"${GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}/\"," >> executor.json
echo "\"buildUrl\":\"https://github.com/${INPUT_GITHUB_REPO}/actions/runs/${INPUT_GITHUB_RUN_ID}\"," >> executor.json
echo "\"buildName\":\"GitHub Actions Run #${INPUT_GITHUB_RUN_ID}\",\"buildOrder\":\"${INPUT_GITHUB_RUN_NUM}\"}" >> executor.json
#cat executor.json
mv ./executor.json ./${INPUT_ALLURE_RESULTS}

#environment.properties
echo "URL=${GITHUB_PAGES_WEBSITE_URL}" >> ./${INPUT_ALLURE_RESULTS}/environment.properties

echo "keep allure history from ${INPUT_GH_PAGES}/last-history to ${INPUT_ALLURE_RESULTS}/history"
cp -r ./${INPUT_GH_PAGES}/last-history/. ./${INPUT_ALLURE_RESULTS}/history

echo "generating report from ${INPUT_ALLURE_RESULTS} to ${INPUT_ALLURE_REPORT} ..."
#ls -l ${INPUT_ALLURE_RESULTS}
allure generate --clean ${INPUT_ALLURE_RESULTS} -o ${INPUT_ALLURE_REPORT}
#echo "listing report directory ..."
#ls -l ${INPUT_ALLURE_REPORT}

echo "copy allure-report to ${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}"
cp -r ./${INPUT_ALLURE_REPORT}/. ./${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}
echo "copy allure-report history to /${INPUT_ALLURE_HISTORY}/last-history"
cp -r ./${INPUT_ALLURE_REPORT}/history/. ./${INPUT_ALLURE_HISTORY}/last-history
