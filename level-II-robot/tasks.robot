*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...                 At least I hope it will.

Library             RPA.Archive
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Dialogs
Library             RPA.FileSystem
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Robocorp.Vault
Library             RPA.Tables


*** Variables ***
${TEMP_PDF}     ${CURDIR}${/}temp_pdf
${TEMP_PNG}     ${CURDIR}${/}temp_png


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Set up temp directories
    Open the robot order website
    ${orders}=    Get Orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create ZIP from PDF receipts
    # Cleanup temp directories
    # Cleanup doesn't work in control room, because "close pdf" keyword doesn't work in control room
    [Teardown]    Close Browser


*** Keywords ***
Ask URL for csv file
    # The url to be entered: https://robotsparebinindustries.com/orders.csv
    Add heading    Please enter url for order csv file
    Add text    Hint: it's https://robotsparebinindustries.com/orders.csv
    Add text input    url
    ${result}=    Run dialog
    RETURN    ${result.url}

Cleanup temp directories
    Remove Directory    ${TEMP_PDF}    True
    Remove Directory    ${TEMP_PNG}    True

Create ZIP from PDF receipts
    ${ZIP_file_name}=    Set Variable    ${OUTPUT_DIR}${/}receipts.zip
    Archive Folder With Zip    ${TEMP_PDF}    ${ZIP_file_name}

Set up temp directories
    Create Directory    ${TEMP_PDF}
    Create Directory    ${TEMP_PNG}

Open the robot order website
    ${website_url}=    Get Secret    order_url
    Open Available Browser    ${website_url}[url]

Get orders
    ${order_url}=    Ask URL for csv file
    Download    ${order_url}    overwrite=True
    ${orders}=    Read table from CSV    orders.csv    header=True
    RETURN    ${orders}

Go to order another robot
    Click Button    order-another

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${files}=    Create List
    ...    ${pdf}
    ...    ${screenshot}
    Add Files To Pdf    ${files}    ${pdf}
    # Close Pdf    ${pdf}    # Doesn't work in control room, don't know why.

Take a screenshot
    [Arguments]    ${order}
    Screenshot    id:robot-preview-image    ${TEMP_PNG}${/}robot_preview_${order}.png
    RETURN    ${TEMP_PNG}${/}robot_preview_${order}.png

Store the receipt as a PDF file
    [Arguments]    ${order}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${TEMP_PDF}${/}receipt_${order}.pdf
    RETURN    ${TEMP_PDF}${/}receipt_${order}.pdf

Submit the order
    Wait Until Keyword Succeeds    10x    0.5 s    Make order

Make order
    Click Button    order
    Page Should Contain    Receipt

Preview the robot
    Click Button    preview

Fill the form
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:input.form-control    ${row}[Legs]
    Input Text    id:address    ${row}[Address]

Close the annoying modal
    Click Button    I guess so...
