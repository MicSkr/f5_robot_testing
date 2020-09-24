*** Settings ***
Documentation    This test configures parameters for "net interface" objects on the BIG-IP
Resource    f5-robot-library-unrefined.robot
Resource    robotframework-f5-tmos.robot

*** Variables ***
${PRIMARY_HOSTNAME}                     %{PRIMARY_HOSTNAME}
${PRIMARY_MGMT_IP}                      %{PRIMARY_MGMT_IP}
${PRIMARY_HTTP_USERNAME}                %{PRIMARY_HTTP_USERNAME}
${PRIMARY_HTTP_PASSWORD}                %{PRIMARY_HTTP_PASSWORD}
${SECONDARY_HOSTNAME}                   %{SECONDARY_HOSTNAME}
${SECONDARY_MGMT_IP}                    %{SECONDARY_MGMT_IP}
${SECONDARY_HTTP_USERNAME}              %{SECONDARY_HTTP_USERNAME}
${SECONDARY_HTTP_PASSWORD}              %{SECONDARY_HTTP_PASSWORD}
${PRIMARY_BASE_UCS_FILENAME}            %{PRIMARY_BASE_UCS_FILENAME}
${SECONDARY_BASE_UCS_FILENAME}          %{SECONDARY_BASE_UCS_FILENAME}

*** Test Cases ***
Perform BIG-IP Quick Check
    [Documentation]    Verifies that key BIG-IP services are in a ready state
    set log level    trace
    Wait until Keyword Succeeds    50x    5 seconds    Verify All BIG-IP Ready States    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    Wait until Keyword Succeeds    50x    5 seconds    Check for BIG-IP Services Waiting to Restart    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    Wait until Keyword Succeeds    50x    5 seconds    Verify All BIG-IP Ready States    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${HTTP_USERNAME}    bigip_password=${HTTP_PASSWORD}
    Wait until Keyword Succeeds    50x    5 seconds    Check for BIG-IP Services Waiting to Restart    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}

Reset Statistics on the BIG-IP
    [Documentation]    Resets all interface, virtual, pool, node, etc statistics on the BIG-IP
    set log level    trace
    Reset All Statistics        bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    Reset All Statistics        bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}

Get List of BIG-IP Interfaces
    [Documentation]    Simply logs a list of all detected BIG-IP interfaces (https://support.f5.com/csp/article/K14107)
    set log level    trace
    List all BIG-IP Interfaces    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    List all BIG-IP Interfaces    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}

Gather Interface Media Capabilities
    [Documentation]    Shows which each physical port capabilities (https://support.f5.com/csp/article/K14107)
    set log level    trace
    ${media-capabilities}    set variable    Retrieve BIG-IP Interface Media Capabilities    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    log    ${media-capabilities}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    ${media-capabilities}    set variable    Retrieve BIG-IP Interface Media Capabilities    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}
    log    ${media-capabilities}

Configure F5 BIG-IP Data Plane Interfaces
    [Documentation]    Configures the BIG-IP interfaces (not including the management interface)
    set log level    trace
    ${PHYS_INTERFACE_LIST}    to json    ${PRIMARY_PHYS_INTERFACE_DETAILS}
    :FOR    ${current_interface}    IN    @{PHYS_INTERFACE_LIST}
    \   ${current_interface_name}    get from dictionary    ${current_interface}    name
    \   ${current_interface_description}    get from dictionary    ${current_interface}    description
    \   ${current_interface_lldpadmin}    get from dictionary    ${current_interface}    lldpAdmin
    \   Configure BIG-IP Interface Description    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}    interface_name=${current_interface_name}    interface_description=${current_interface_description}
    \   run keyword if    '${current_interface_lldpadmin}'=='txrx'    Set BIG-IP Interface LLDP to Transmit and Receive   bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
    \   run keyword if    '${current_interface_lldpadmin}'=='txonly'    Set BIG-IP Interface LLDP to Transmit Only    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
    \   run keyword if    '${current_interface_lldpadmin}'=='rxonly'    Set BIG-IP Interface LLDP to Receive Only    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
    \   run keyword if    '${current_interface_lldpadmin}'=='disable'   Disable BIG-IP LLDP on Interface    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    ${PHYS_INTERFACE_LIST}    to json    ${SECONDARY_PHYS_INTERFACE_DETAILS}
    :FOR    ${current_interface}    IN    @{PHYS_INTERFACE_LIST}
    \   ${current_interface_name}    get from dictionary    ${current_interface}    name
    \   ${current_interface_description}    get from dictionary    ${current_interface}    description
    \   ${current_interface_lldpadmin}    get from dictionary    ${current_interface}    lldpAdmin
    \   Configure BIG-IP Interface Description    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}    interface_name=${current_interface_name}    interface_description=${current_interface_description}
    \   run keyword if    '${current_interface_lldpadmin}'=='txrx'    Set BIG-IP Interface LLDP to Transmit and Receive   bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
    \   run keyword if    '${current_interface_lldpadmin}'=='txonly'    Set BIG-IP Interface LLDP to Transmit Only    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
    \   run keyword if    '${current_interface_lldpadmin}'=='rxonly'    Set BIG-IP Interface LLDP to Receive Only    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
    \   run keyword if    '${current_interface_lldpadmin}'=='disable'   Disable BIG-IP LLDP on Interface    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}   interface_name=${current_interface_name}
