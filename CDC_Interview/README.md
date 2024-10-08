# Background
This project is in a partially completed state, initiated by a junior developer. We’d love your help to finish it and resolve some outstanding issues.

## Aim
We’re interested in learning more about you, including your coding style, design pattern preferences, codebase management, Git commit practices, testing habits, and especially your experience with reactive programming. Through this assignment, we aim to get a general sense of these areas before moving forward to the next stage.

## What This App Does:
1. It fetches and displays a list of supported cryptocurrencies with their corresponding prices.
    1.1 The v1 API call is simulated by reading the `usdPrices.json` file.
2. It allows users to search for a specific token via the search text field at the top.
3. It navigates to a detail page (`USDItemDetailsViewController`) when a user selects an item from the list.
    3.1 The current detail page shows the token's price and tags.

## Tasks
1. Complete the search function, which is currently not returning any results after text input.
2. Implement functionality to display the EUR price in addition to the USD price in the UI.
    2.1 The ability to show the EUR price is controlled by a feature flag, `Support EUR`, located in the Settings page (`SettingViewController`).
    2.2 When toggled **off**, keep the existing behavior unchanged.
    2.3 When toggled **on**, simulate the v2 API call using the `allPrices.json` file instead.
        2.3.1 Upon selecting a token, the user should be navigated to a new detail page where both USD and EUR prices are shown. The old page and v1 API support will be deprecated.
        2.3.2 The EUR price should be displayed right below the USD price on the new detail page:

            |back ---BTC-----|  
            |usd: ###--------|  
            |eur: ###--------|  
            |tag1------------|  
            |tag2------------|

3. Add any necessary unit tests, for example, covering the data layer, view model, etc.
4. Please review the code and practices used in the project. You are free to modify any part of the project as you see fit, whether it’s improving the architecture, introducing SwiftUI, or anything else.
5. Continue using Git and commit your changes regularly.
6. Feel free to elaborate on and leave comments regarding any changes you have made, either in the code or as an appendix to this README.
