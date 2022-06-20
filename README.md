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
    allure_results: allure-results
    gh_pages: gh-pages
    allure_report: allure-report
    allure_history: allure-history
    test_env: QA
```

## Example usage (github action)

```yaml
- name: Test marketplace action
  uses: PavanMudigonda/allure-html-reporter-github-pages@main
  if: always()
  id: allure-report
  with:
    allure_results: allure-results
    gh_pages: gh-pages
    allure_report: allure-report
    allure_history: allure-history    
```

## Publish to GitHub Pages

```yaml
- name: Deploy report to Github Pages
  if: always()
  uses: peaceiris/actions-gh-pages@v3
  env:
    PERSONAL_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    PUBLISH_BRANCH: gh-pages
    PUBLISH_DIR: allure-history
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

## Sample Screenshot

<img width="666" alt="image" src="https://user-images.githubusercontent.com/29324338/174334674-9ad8df6f-1a50-4cce-b30b-b39b82415d45.png">



## Sample GH Pages Screenshot

<img width="1440" alt="image" src="https://user-images.githubusercontent.com/29324338/174334734-8e3857d6-3a95-4027-832c-c512c3997aca.png">

