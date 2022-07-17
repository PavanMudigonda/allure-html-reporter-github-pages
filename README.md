| **Reporter**        | **Github Pages**   | **Azure Storage Static Website** | **AWS S3 Static Website**                                                                    |
|---------------------|--------------------|-------------------------------|----------------------------------------------------------------------------------------------|
| **Allure HTML**     | [GH Action Link](https://github.com/marketplace/actions/allure-html-reporter-github-pages) | [GH Action Link](https://github.com/marketplace/actions/allure-html-reporter-azure-website)            | [GH Action Link](https://github.com/marketplace/actions/allure-html-reporter-aws-s3-website )      |
| **Any HTML Reports** | [GH Action Link](https://github.com/marketplace/actions/html-reporter-github-pages) | [GH Action Link](https://github.com/marketplace/actions/html-reporter-azure-website)            | [GH Action Link](https://github.com/marketplace/actions/html-reporter-aws-s3-website) |



# Allure Report with history action

Generates Allure Report with history.

Example workflow file [allure-html-reporter-github-pages](https://github.com/PavanMudigonda/allure-html-reporter-github-pages/blob/main/.github/workflows/main.yml)

## Inputs

### `allure_results`

**Required** The relative path to the Allure results directory. 

Default `allure-results`

### `allure_report`

**Required** The relative path to the directory where Allure will write the generated report. 

Default `allure-report`

### `gh_pages`

**Required** The relative path to the `gh-pages` branch folder. On first run this folder can be empty.
Also, you need to do a checkout of `gh-pages` branch, even it doesn't exist yet.

Default `gh-pages`

```yaml
- name: Get Allure history
  uses: actions/checkout@v2
  if: always()
  continue-on-error: true
  with:
    ref: gh-pages
    path: gh-pages
```

### `allure_history`

**Required** The relative path to the folder, that will be published to GitHub Pages.

Default `allure-history`

### `subfolder`

The relative path to the project folder, if you have few different projects in the repository. 
This relative path also will be added to GitHub Pages link. 

Default ``

## Example usage (local action)

```yaml
- name: Test local action
  uses: ./allure-html-reporter-github-pages
  if: always()
  id: allure-report
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    workflow_id: main.yml
    allure_results: allure-results
    gh_pages: gh-pages
    test_env: QA
```

## Example usage (github action)

```yaml
- name: Test marketplace action
  uses: PavanMudigonda/allure-html-reporter-github-pages@v1.0
  if: always()
  id: allure-report
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    workflow_id: main.yml
    allure_results: allure-results
    gh_pages: gh-pages
```

## Publish to GitHub Pages

```yaml
      - name: Publish Github Pages
        if: ${{ always() }}
        uses: peaceiris/actions-gh-pages@v3.8.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_branch: gh-pages
          publish_dir: allure-history. # Previous Step provides output folder "allure-history" this needs to be uploaded to Github Pages
          keep_files: true 
```

## Also you can post the link to the report in the checks section

```yaml
- name: Post the link to the report
  if: always()
  uses: Sibz/github-status-action@v1
  with: 
      authToken: ${{secrets.GITHUB_TOKEN}}
      context: 'Test report'
      state: 'success'
      sha: ${{ github.event.pull_request.head.sha }}
      target_url: PavanMudigonda.github.io/allure-html-reporter-github-pages/${{ github.run_number }}
```

## Also you can post link to the report to MS Teams
```yaml

- name: Message MS Teams Channel
  uses: toko-bifrost/ms-teams-deploy-card@master
  with:
    github-token: ${{ github.token }}
    webhook-uri: ${{ secrets.MS_TEAMS_WEBHOOK_URI }}
    custom-facts: |
      - name: Github Actions Test Results
        value: "http://example.com/${{ github.run_id }}"
    custom-actions: |
      - text: View CI Test Results
        url: "https://PavanMudigonda.github.io/html-reporter-github-pages/${{ github.run_number }}"
 ```
 
 ## Also you can post link to the report to MS Outlook
 
 ```yaml
 
 
 - name: Send mail
  uses: dawidd6/action-send-mail@v3
  with:
    # Required mail server address:
    server_address: smtp.gmail.com
    # Required mail server port:
    server_port: 465
    # Optional (recommended): mail server username:
    username: ${{secrets.MAIL_USERNAME}}
    # Optional (recommended) mail server password:
    password: ${{secrets.MAIL_PASSWORD}}
    # Required mail subject:
    subject: Github Actions job result
    # Required recipients' addresses:
    to: obiwan@example.com,yoda@example.com
    # Required sender full name (address can be skipped):
    from: Luke Skywalker # <user@example.com>
    # Optional whether this connection use TLS (default is true if server_port is 465)
    secure: true
    # Optional plain body:
    body: Build job of ${{github.repository}} completed successfully!
    # Optional HTML body read from file:
    html_body: file://README.html
    # Optional carbon copy recipients:
    cc: kyloren@example.com,leia@example.com
    # Optional blind carbon copy recipients:
    bcc: r2d2@example.com,hansolo@example.com
    # Optional recipient of the email response:
    reply_to: luke@example.com
    # Optional Message ID this message is replying to:
    in_reply_to: <random-luke@example.com>
    # Optional unsigned/invalid certificates allowance:
    ignore_cert: true
    # Optional converting Markdown to HTML (set content_type to text/html too):
    convert_markdown: true
    # Optional attachments:
    attachments: attachments.zip,git.diff,./dist/static/*.js
    # Optional priority: 'high', 'normal' (default) or 'low'
    priority: low
 ```
 
## Sample Screenshot

<img width="555" alt="image" src="https://user-images.githubusercontent.com/29324338/178267219-ab004598-3afa-4ecb-9e1d-fa769bb0f5bc.png">


## Sample GH Pages Screenshot

<img width="1440" alt="image" src="https://user-images.githubusercontent.com/29324338/174334734-8e3857d6-3a95-4027-832c-c512c3997aca.png">

