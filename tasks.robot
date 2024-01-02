*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.Excel.Files
Library    RPA.PDF
Library    RPA.Archive

Suite Teardown      Close All Browsers

*** Variables ***
${URL}=                         https://robotsparebinindustries.com/

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download orders file
    Process orders file
    Create a ZIP file of receipt PDF files
    
*** Keywords ***
Open the robot order website
    Open Available Browser    ${URL}#/robot-order
    
Close the annoying modal
    Click Button When Visible    class:btn-dark

Download orders file
    Download    ${URL}orders.csv    overwrite=True

Process orders file
    ${orders}=    Read table from CSV    orders.csv

    FOR    ${order}    IN    @{orders}
        Fill the form    ${order}
    END

Fill the form
    [Arguments]    ${order}
    Close the annoying modal
    #Head
    Select From List By Value    id:head    ${order}[Head]
    #Body
    Select Radio Button    body    ${order}[Body]
    #Legs
    Input Text    class:form-control    ${order}[Legs]
    #Address 
    Input Text    id:address    ${order}[Address]

    Click Button    preview
    
    Click Button    order
    
    ${present}=  Run Keyword And Return Status    Element Should Be Visible   css:div.alert.alert-danger

    Run Keyword If    ${present}    Click Button Order
    
    Store PDF    ${order}

    Click Button When Visible    order-another

Click Button Order
    Click Button    order
    
Store PDF
    [Arguments]    ${order}
    
    Wait Until Element Is Visible    id:receipt
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML

    Html To Pdf    ${order_receipt}    ${OUTPUT_DIR}${/}order_result${order}[Order number].pdf
    
    Embed the robot screenshot to the receipt PDF file    ${order}

Embed the robot screenshot to the receipt PDF file 
    [Arguments]    ${order}
    
    Wait Until Element Is Visible    id:robot-preview-image
    ${img}=    Screenshot    id:robot-preview-image        ${OUTPUT_DIR}${/}robot${order}[Order number].png
    
    Open Pdf    ${OUTPUT_DIR}${/}order_result${order}[Order number].pdf
    ${files}=    Create List    ${img} 
    Add Files To Pdf    ${files}   ${OUTPUT_DIR}${/}order_result${order}[Order number].pdf    True
    Save Pdf    ${OUTPUT_DIR}${/}order_result${order}[Order number].pdf
    Close Pdf    ${OUTPUT_DIR}${/}order_result${order}[Order number].pdf

Create a ZIP file of receipt PDF files
    Archive Folder With Zip    ${OUTPUT_DIR}${/}    bought_robots.zip