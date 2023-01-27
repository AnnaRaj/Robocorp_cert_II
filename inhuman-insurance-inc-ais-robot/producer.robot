*** Settings ***
Documentation       Inhuman Incurance, Inc. Artifical Intelligence System robot.
...                 Produces traffic data work items.

Library             RPA.HTTP
Library             RPA.JSON
Library             RPA.Tables


*** Variables ***
${TRAFFIC_JSON_FILE_PATH}=      ${OUTPUT_DIR}${/}traffic.json


*** Tasks ***
Produce traffic data work items
    Download traffic data
    ${traffic_data}=    Load traffic data as table
    ${filtered_data}=    Filter and sort traffic data    ${traffic_data}
    Write Table To Csv    ${traffic_data}    test.csv


*** Keywords ***
Download traffic data
    Download
    ...    https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
    ...    ${TRAFFIC_JSON_FILE_PATH}
    ...    overwrite=True

Load traffic data as table
    ${json}=    Load JSON from file    ${TRAFFIC_JSON_FILE_PATH}
    ${table}=    Create Table    ${json}[value]
    RETURN    ${table}

Filter and sort traffic data
    [Arguments]    ${table}
    ${max_rate}=    Set Variable    ${5.0}
    ${rate_key}=    Set Variable    NumericValue
    ${gender_key}=    Set Variable    Dim1
    ${both_genders}=    Set Variable    BTSX
    ${year_key}=    Set Variable    TimeDim
    Filter Table By Column    ${table}    ${rate_key}    <    ${max_rate}
    Filter Table By Column    ${table}    ${gender_key}    ==    ${both_genders}
    Sort Table By Column    ${table}    ${year_key}    False
    RETURN    ${table}
