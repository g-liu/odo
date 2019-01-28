<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ page session="false" %>
<html>
<head>
    <title>History: ${profile_name}</title>
    <%@ include file="/resources/js/webjars.include" %>
    <script src="<c:url value="/resources/js/diff_match_patch_uncompressed.js" />"></script>
    <link rel="stylesheet" type="text/css" media="screen"
             href="<c:url value="/resources/css/odo.css"/>" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <script type="text/javascript">
        $.jgrid.no_legacy_api = true;
        $.jgrid.useJSON = true;
    </script>

     <style type="text/css">
         ul, li {
             list-style-type: none;
         }

        .has-switch {height: 30px}

        .altRowClass { background: #EEEEEE; }

        textarea.preformatted { font-family: monospace; }
     </style>
</head>
<body>
<%@ include file="pathtester_part.jsp" %>

<!-- Hidden div for grid options -->
<div id="gridOptionsDialog" style="display:none;">
    <table>
    <tr><td>
        Number of Rows:
    </td><td>
        <input id="numberOfRows" size=5/>
    </td></tr>
    </table>
</div>

<nav class="navbar navbar-default smaller-center" role="navigation">
    <div class="container-fluid">
        <div class="navbar-header">
            <a class="navbar-brand" href="#">Odo</a>
        </div>

        <div class="form-group navbar-form navbar-left">
            <input type="text" class="form-control" placeholder="Search" id="searchFilter">
            <button class="btn btn-default" type="button" onclick='uriFilter()'>Apply Filter</button>
            <button class="btn btn-default" type="button" onclick='clearFilter()'>Clear Filters</button>

            <span class="dropdown">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Filter By <span class="caret"></span>
                </button>

                <ul class="dropdown-menu">
                    <li><a href="#" onclick='showItemsWithMessages()'>Items With Messages</a></li>
                </ul>
            </span>
        </div>


       <ul class="nav navbar-nav navbar-right">
         <li><a href="#" onclick='clearHistory()'>Clear History</a></li>
         <li><a href="#" onclick='navigateScripts()'>Edit Scripts</a></li>
         <li><a href="#" onclick='openGridOptions()'>Grid Options</a></li>
       </ul>
    </div>
</nav>
<div class="smaller-center" id="historyGridDiv">
    <table id="historylist"></table>
    <div id="historynavGrid"></div>
</div>
<br />
    <div class="smaller-center" id="historyContentDiv">
        <div id="tabs">
            <ul>
                <li><a href="#tabs-1">Response</a></li>
                <li><a href="#tabs-2">Request</a></li>
                <li><a href="#tabs-3">Other</a></li>
            </ul>

            <div id="tabs-1">
                <div class="btn-group btn-group-sm pull-right" id="responseButtons">
                    <button type="button" class="btn btn-default" id="showModifiedResponseButton" onClick="showModifiedResponse()">Modified</button>
                    <button type="button" class="btn btn-default" id="showOriginalResponseButton" onClick="showOriginalResponse()">Original</button>
                    <button type="button" class="btn btn-default" id="showChangedResponseButton" onClick="showChangedResponse()">View Diff</button>
                </div>

                <h3>Headers</h3>

                <textarea readonly class="form-control preformatted" rows="4" id="responseHeaders"></textarea>
                <textarea readonly class="form-control preformatted" rows="4" style="display: none;" id="originalResponseHeaders"></textarea>
                <div class="form-control" id = "originalResponseHeaderChange" style="width: 100%; height: 80px; overflow-y: scroll; resize: vertical; display: none;"></div>
                <div style="clear: both"></div>

                <h3>Data <span class="label label-info label-small" id="responseTypeLabel"></span> <span class="label label-info label-small" id="responseDataDecodedLabel" style="background-color: #5b7fde"></span></h3>

                <div class="d-inline-block btn-group btn-group-sm">
                    <button type="button" class="btn btn-default" id="showRawResponseDataButton" onClick="showRawResponseData()">Raw</button>
                    <button type="button" class="btn btn-default" id="showRawFormattedDataButton" onClick="showFormattedResponseData(false)">Formatted</button>
                </div>

                <div class="d-inline-block btn-group btn-group-sm">
                    <button type="button" class="btn btn-default" id="downloadResponseDataButton" onClick="downloadResponseData()">Export Response</button>
                </div>

                <textarea readonly class="form-control preformatted" rows="20" id="responseRaw"></textarea>
                <textarea readonly class="form-control preformatted" rows="20" style="display: none;" id="originalResponseRaw"></textarea>
                <div class="form-control" id = "originalResponseChange" style="width: 100%; height: 450px; overflow-y: scroll;  resize: vertical; display: none;"></div>
            </div><!-- /#tabs-1 -->

            <div id="tabs-2">
                <div class="btn-group btn-group-sm pull-right" id="requestButtons">
                    <button type="button" class="btn btn-default" id="showModifiedRequestButton" onClick="showModifiedRequestData()">Modified</button>
                    <button type="button" class="btn btn-default" id="showOriginalButton" onClick="showOriginalRequestData()">Original</button>
                    <button type="button" class="btn btn-default" id="showChangedButton" onClick="showChangedRequestData()">View Diff</button>
                </div>

                <h3>URL</h3>
                <div class="d-inline-block btn-group btn-group-sm">
                    <button type="button" class="btn btn-default" onClick="showPathTester()">Test Path</button>
                </div>
                <textarea readonly class="form-control preformatted" rows="1" id="requestQuery"></textarea>
                <textarea readonly class="form-control preformatted" rows="1" style="display: none;" id="originalRequestQuery"></textarea>
                <div class="form-control" id = "originalRequestQueryChange" style="width: 100%; height: 40px; overflow-y: scroll; resize: vertical; display: none;"></div>
                <div style="clear: both"></div>

                <h3>Parameters</h3>
                <textarea readonly class="form-control preformatted" rows="3" id="requestParameters"></textarea>
                <textarea readonly class="form-control preformatted" rows="3" style="display: none;" id="originalRequestParameters"></textarea>
                <div class="form-control" style="width: 100%; float: left; display: none; overflow-y: scroll; resize: vertical;" id="originalRequestParametersChanged"></div>
                <div style="clear: both"></div>

                <h3>Headers</h3>
                <textarea readonly class="form-control preformatted" rows="3" id="requestHeaders"></textarea>
                <textarea readonly class="form-control preformatted" rows="3" style="display: none;" id="originalRequestHeaders"></textarea>
                <div class="form-control" style="width: 100%; height: 80px; float: left; display: none; overflow-y: scroll; resize: vertical;" id="originalRequestHeadersChanged"></div>
                <div style="clear: both"></div>

                <h3>POST Data <span class="label label-info label-small" id="requestDataDecodedLabel" style="background-color: #5b7fde"></span></h3>
                <textarea readonly class="form-control preformatted" rows="10" id="requestPOSTData"></textarea>
                <textarea readonly class="form-control preformatted" rows="10" style="display: none" id="originalRequestPOSTData"></textarea>
                <div class="form-control" style="width: 100%; height: 80px; float: left; display: none; overflow-y: scroll; resize: vertical;" id="originalRequestPOSTDataChanged"></div>
            </div><!-- /#tabs-2 -->

            <div id="tabs-3">
                <h3>cURL Command</h3>
                <textarea readonly class="form-control preformatted" rows="30" id="curlCommand"></textarea>
            </div><!-- /#tabs-3 -->
        </div>
    </div>

<script>
    var clientUUID = '${clientUUID}';

    function openGridOptions() {
        $("#gridOptionsDialog").dialog({
            title: "Grid Options",
            width: 750,
            modal: true,
            position:['top',20],
            buttons: {
              "Save": function() {
                  if (! isNaN($("#numberOfRows").val())) {
                      $.cookie("historyGridRows", $("#numberOfRows").val(), { expires: 10000, path: '/testproxy/history' });
                  }
                  $("#gridOptionsDialog").dialog("close");
                  location.reload();
              },
              "Close": function() {
                  $("#gridOptionsDialog").dialog("close");
              }
            },
            open: function( event, ui ) {
                $("#numberOfRows").val(getNumberOfRows());
            }
        });
    }

    function getNumberOfRows() {
        var numRows = 10;
        if ($.cookie("historyGridRows") != null) {
            numRows = $.cookie("historyGridRows");
        }

        return numRows;
    }

    function navigateScripts() {
        window.open('<c:url value = '/scripts' />');
    }

    function noenter() {
        return !(window.event && window.event.keyCode == 13);
    }

    function clearHistory() {
        $.ajax({
            type : "POST",
            url : '<c:url value="/api/history/${profile_id}"/>',
            data : ({
                clientUUID : clientUUID,
                _method : 'DELETE'
            }),
            success : function(data) { //this is the data that comes back from the server (the array<array<object>>)
                historyList.trigger("reloadGrid");
            },
            error : function(xhr, ajaxOptions, thrownError) {
                $('#info').html("Whoops!");
            }
        });
    }

    function uriFilter() {
        var filter = $("#searchFilter").val();
        jQuery("#historylist")
                .jqGrid(
                        'setGridParam',
                        {
                            url : '<c:url value="/api/history/${profile_id}"/>?clientUUID=${clientUUID}&source_uri[]='
                                    + filter,
                            page : 1
                        }).trigger("reloadGrid");
    }

    function showItemsWithMessages() {
        jQuery("#historylist")
            .jqGrid(
                'setGridParam',
                {
                    url : '<c:url value="/api/history/${profile_id}"/>?clientUUID=${clientUUID}&hasMessage=true',
                    page : 1
                }).trigger("reloadGrid");
    }

    function clearFilter() {
        jQuery("#historylist")
                .jqGrid(
                        'setGridParam',
                        {
                            url : '<c:url value="/api/history/${profile_id}"/>?clientUUID=${clientUUID}',
                            page : 1
                        }).trigger("reloadGrid");
    }


    var currentHistoryId = -1;

    // this just sets the current path ID so that other formatters can use it
    function idFormatter(cellvalue, options, rowObject) {
        currentHistoryId = cellvalue;
        return cellvalue;
    }

    function dateFormatter(cellvalue, options, rowObject) {
      var date = new Date(cellvalue)

      if (date instanceof Date && isFinite(date)) {
        var options = { hour: '2-digit', minute: '2-digit', second: '2-digit', month: 'short', day: 'numeric' };
        return date.toLocaleDateString("en-US", options);
      }

      return cellvalue;
    }

    var invalidRows = []
    function validFormatter(cellvalue, options, rowObject) {
        if (cellvalue == false) {
            invalidRows[invalidRows.length] = options.rowId;
        }
        return cellvalue;
    }

    var originalResponseFlag = 0;

    function showOriginalResponse(){
        originalResponseFlag = 1;
        $("#originalResponseHeaders").val(historyData.history.originalResponseHeaders);
        if(historyData.history.responseContentType == null ||
            historyData.history.responseContentType.toLowerCase().indexOf("application/json") == -1 ||
            historyData.history.responseData == "" || $.cookie("formatted") == "false"){
                $("#originalResponseRaw").val(originalResponseRaw);
        } else {
            if(historyData.history.formattedOriginalResponseData == "") {
                showFormattedResponseData(false);
            } else {
                $("#originalResponseRaw").val(historyData.history.formattedOriginalResponseData);
            }
        }
        $("#originalResponseHeaders").show();
        $("#originalResponseRaw").show();
        $("#originalResponseHeaderChange").hide();
        $("#originalResponseChange").hide();
        $("#responseRaw").hide();
        $("#responseHeaders").hide();
        $("#showChangedResponseButton, #showModifiedResponseButton").attr("class", "btn btn-default");
        $("#showOriginalResponseButton").attr("class", "btn btn-primary");
    }

    var dmp = new diff_match_patch();
    function showChangedData(originalData, changedData, originalID, changedID, modifiedID){
        var d = dmp.diff_main(originalData, changedData);
        dmp.diff_cleanupSemantic(d);
        var ds = diff_prettyHtml(d);
        //$("#" + changedID).html(ds.replace(/[^\x00-\x7F]/g, ""));
        $("#" + changedID).html(ds);
        $("#" + originalID).hide();
        $("#" + changedID).show();
        $("#" + modifiedID).hide();
    }

    function showChangedResponse(){
        showFormattedResponseData(true);
    }

    function showChangedResponsePostFormattedAJAX() {
        showChangedData(historyData.history.formattedOriginalResponseData, historyData.history.formattedResponseData, "originalResponseRaw", "originalResponseChange", "responseRaw");
        $("#showChangedResponseButton").attr("class", "btn btn-primary");
        $("#showOriginalResponseButton, #showModifiedResponseButton").attr("class", "btn btn-default");
    }

    function showModifiedResponse(){
        originalResponseFlag = 0;
        $("#responseHeaders").val(historyData.history.responseHeaders);
        if(historyData.history.responseContentType == null ||
            historyData.history.responseContentType.toLowerCase().indexOf("application/json") == -1 ||
            historyData.history.responseData == "" || $.cookie("formatted") == "false") {
                $("#responseRaw").val(responseRaw);
        } else {
            if(historyData.history.formattedResponseData == "") {
                showFormattedResponseData(false);
            } else {
                $("#responseRaw").val(historyData.history.formattedResponseData);
            }
        }
        $("#responseHeaders").show();
        $("#responseRaw").show();
        $("#originalResponseHeaderChange").hide();
        $("#originalResponseChange").hide();
        $("#originalResponseRaw").hide();
        $("#originalResponseHeaders").hide();
        $("#showOriginalResponseButton, #showChangedResponseButton").attr("class", "btn btn-default");
        $("#showModifiedResponseButton").attr("class", "btn btn-primary");
    }

    var responseRaw, originalResponseRaw;
    function showFormattedResponseData(forDiff) {
        $.ajax({
            type : "GET",
            url : '<c:url value="/api/history/${profile_id}/"/>'
                + currentHistoryId,
            data : 'clientUUID=${clientUUID}&format=formattedAll',
            success : function(data) {
                historyData = data;
                if (forDiff == true) {
                    showChangedResponsePostFormattedAJAX();
                } else {
                    $("#responseRaw").val(data.history.formattedResponseData);
                    $("#originalResponseRaw").val(data.history.formattedOriginalResponseData);
                    $.cookie("formatted", "true");
                    $("#showRawFormattedDataButton").attr("class", "btn btn-primary");
                    $("#showRawResponseDataButton").attr("class", "btn btn-default");
                }
            }
        });
    }

    function showRawResponseData() {
        responseRaw = historyData.history.responseData;
        originalResponseRaw = historyData.history.originalResponseData;
        $("#responseRaw").val(responseRaw);
        $("#originalResponseRaw").val(originalResponseRaw);
        $.cookie("formatted", "false");
        $("#showRawResponseDataButton").attr("class", "btn btn-primary");
        $("#showRawFormattedDataButton").attr("class", "btn btn-default");
    }

    function showOriginalRequestData(){
        $("#originalRequestQuery").show();
        $("#originalRequestQueryChange").hide();
        $("#requestQuery").hide();
        $("#originalRequestParameters").show();
        $("#originalRequestParameters").css("height" , "");
        $("#originalRequestParameters").height($("#originalRequestParameters")[0].scrollHeight + "px");
        $("#originalRequestParametersChanged").hide();
        $("#requestParameters").hide();
        $("#originalRequestHeaders").show();
        $("#originalRequestHeadersChanged").hide();
        $("#requestHeaders").hide();
        $("#originalRequestPOSTData").show();
        $("#originalRequestPOSTDataChanged").hide();
        $("#requestPOSTData").hide();
        $("#showOriginalButton").attr("class", "btn btn-primary");
        $("#showChangedButton, #showModifiedRequestButton").attr("class", "btn btn-default");
    }

    function showChangedRequestData(){
        showChangedData(historyData.history.originalRequestURL, historyData.history.requestURL, "originalRequestQuery", "originalRequestQueryChange", "requestQuery");
        showChangedData(historyData.history.originalRequestParams, historyData.history.requestParams, "originalRequestParameters", "originalRequestParametersChanged", "requestParameters");
        showChangedData(historyData.history.originalRequestHeaders, historyData.history.requestHeaders, "originalRequestHeaders", "originalRequestHeadersChanged", "requestHeaders");
        showChangedData(historyData.history.originalRequestPostData, historyData.history.requestPostData, "originalRequestPOSTData", "originalRequestPOSTDataChanged", "requestPOSTData");
        $("#showChangedButton").attr("class", "btn btn-primary");
        $("#showOriginalButton, #showModifiedRequestButton").attr("class", "btn btn-default");
    }

    function showModifiedRequestData(){
        $("#originalRequestQuery").hide();
        $("#originalRequestQueryChange").hide();
        $("#requestQuery").show();
        $("#originalRequestParameters").hide();
        $("#originalRequestParametersChanged").hide();
        $("#requestParameters").show();
        $("#originalRequestHeaders").hide();
        $("#originalRequestHeadersChanged").hide();
        $("#requestHeaders").show();
        $("#originalRequestPOSTData").hide();
        $("#originalRequestPOSTDataChanged").hide();
        $("#requestPOSTData").show();
        $("#showOriginalButton, #showChangedButton").attr("class", "btn btn-default");
        $("#showModifiedRequestButton").attr("class", "btn btn-primary");
    }


    function showCurlCommand() {
        var headers = historyData.history.requestHeaders.split('\n');
        var requestType = historyData.history.requestType;

        var commandLine = "curl --insecure -X " + requestType;
        for ( var x in headers) {
            if(headers[x].toLowerCase().lastIndexOf("content-length",0) === 0) {
                continue;
            }
            commandLine += " -H '" + headers[x].replace("'", "\\u0027") + "'";
        }

        if (historyData.history.requestPostData != null
                && historyData.history.requestPostData !== "") {
            commandLine += " -d '" + historyData.history.requestPostData.replace("'", "\\u0027")
                    + "'";
        }

        commandLine += " '" + historyData.history.requestURL;

        if (historyData.history.requestParams != null
                && historyData.history.requestParams !== "") {
            commandLine += "?" + historyData.history.requestParams;
        }

        commandLine += "'";

        $("#curlCommand").val(commandLine);
    }

    //http://stackoverflow.com/questions/17564103/using-javascript-to-download-file-as-a-csv-file
    function downloadResponseData() {
        var responseDownload = $("<a>")
            .attr("download", "response");
        if (originalResponseFlag == 1) {
            responseDownload.attr("href", "data:text/json;charset=utf-8," + historyData.history.originalResponseData);
        } else {
            responseDownload.attr("href", "data:text/json;charset=utf-8," + historyData.history.responseData);
        }
        $("body").append(responseDownload)
        responseDownload.click();
    }

    var historyData;
    function loadData(historyId) {
        $.ajax({
            type : "GET",
            url : '<c:url value="/api/history/${profile_id}/"/>'
                + historyId,
            data : 'clientUUID=${clientUUID}',
            success : function(data) {
                // populate data
                historyData = data;

                // optionally turn off the Formatted button
                if (data.history.responseContentType == null
                    || data.history.responseContentType.toLowerCase().indexOf(
                    "application/json") == -1 || data.history.responseData == "") {
                        showRawResponseData();
                        showModifiedResponse();
                        $("#showRawFormattedDataButton").attr("disabled", "disabled");
                } else {
                    if($.cookie("formatted") == "true") {
                        showFormattedResponseData(false);
                    } else {
                        showRawResponseData();
                        showModifiedResponse();
                    }
                    $("#showRawFormattedDataButton").removeAttr("disabled");
                }

                if (data.history.responseData == "") {
                    $("#downloadResponseDataButton").hide();
                } else {
                    $("#downloadResponseDataButton").show();
                }


                $("#responseHeaders").val(data.history.responseHeaders);
                $("#originalResponseHeaders").val(data.history.originalResponseHeaders);
                $("#responseTypeLabel").html(data.history.responseContentType);
                $("#requestQuery").val(data.history.requestURL);
                $("#requestParameters").val(data.history.requestParams);
                $("#requestHeaders").val(data.history.requestHeaders);
                $("#requestPOSTData").val(data.history.requestPostData);

                if(data.history.modified) {
                    $("#originalResponseHeaders").val(historyData.history.originalResponseHeaders);
                    $("#originalRequestQuery").val(data.history.originalRequestURL);
                    $("#originalRequestParameters").val(data.history.originalRequestParams);
                    $("#originalRequestHeaders").val(data.history.originalRequestHeaders);
                    $("#originalRequestPOSTData").val(data.history.originalRequestPostData);
                    $("#responseButtons").show();
                    $("#requestButtons").show();
                    $("#showModifiedResponseButton, #showModifiedRequestButton").attr("class", "btn btn-primary");
                } else {
                    // set the query back to the original query data
                    $("#requestQuery").val(data.history.originalRequestURL);

                    $("#responseButtons").hide();
                    $("#requestButtons").hide();
                }

                // set response data decoded
                if(data.history.responseBodyDecoded) {
                    // mark as decoded in the UI
                    $("#responseDataDecodedLabel").html("decoded");

                    // try to make the label more specific
                    var headerParts = data.history.responseHeaders.split('\n');
                    for (var x in headerParts) {
                        var parts = headerParts[x].split(": ");
                        console.log(parts[0].toLowerCase());
                        if (parts[0].toLowerCase() === "content-encoding") {
                            $("#responseDataDecodedLabel").html("decoded: " + parts[1]);
                            break;
                        }
                    }
                } else {
                    $("#responseDataDecodedLabel").html("");
                }

                // set request data decoded
                if(data.history.requestBodyDecoded) {
                    // mark as decoded in the UI
                    $("#requestDataDecodedLabel").html("decoded");
                } else {
                    $("#requestDataDecodedLabel").html("");
                }

                showModifiedRequestData();
                showCurlCommand();
            }
        });
    }

    $(document).ready(function() {
        $("#tabs").tabs();
        $("#tabs").css("overflow", "scroll");
        $("#radioset").buttonset();

        $('#searchFilter').keydown(function(event) {
            if (event.keyCode == 13) {
                uriFilter();
                return false;
            }
        });

        // bind window resize to fix grid width
        $(window).bind('resize', function() {
            $("#historylist").setGridWidth($("#historyGridDiv").width());
        });
    });

    var selectRowUsed = false;
    var historyList = jQuery("#historylist");

    historyList
            .jqGrid({
                url : '<c:url value="/api/history/${profile_id}"/>?clientUUID=${clientUUID}',
                autowidth : true,
                pgbuttons : true, // disable page control like next, back button
                pgtext : null,
                datatype : "json",
                page : "${page}",
                rowNum: getNumberOfRows(),
                altRows: true,
                altclass: 'altRowClass',
                colNames : [ 'ID', 'Created At', 'Method', 'Query',
                        'Query Params', 'Code', 'Valid', 'Message', 'Modified' ],
                colModel : [{
                    name : 'id',
                    index : 'id',
                    width : 55,
                    hidden : true,
                    formatter : idFormatter
                }, {
                    name : 'createdAt',
                    index : 'createdAt',
                    width : 150,
                    editable : false,
                    align : 'center',
                    sorttype : 'date',
                    formatter : dateFormatter,
                }, {
                    name : 'requestType',
                    index : 'requestType',
                    width : 50,
                    editable : false,
                    align : 'center'
                }, {
                    name : 'originalRequestURL',
                    index : 'originalRequestURL',
                    width : 375,
                    editable : false,
                    cellattr: function (rowId, tv, rawObject, cm, rdata) {
                        return 'style="white-space: normal; word-break: break-all;"'
                    }
                }, {
                    name : 'requestParams',
                    index : 'requestParams',
                    width : 300,
                    editable : false,
                    cellattr: function (rowId, tv, rawObject, cm, rdata) {
                        return 'style="white-space: normal; word-break: break-all; font-family: monospace;"'
                    }
                }, {
                    name : 'responseCode',
                    index : 'responseCode',
                    width : 50,
                    editable : false,
                    align : 'center'
                }, {
                    name : 'valid',
                    index : 'valid',
                    width : 55,
                    hidden : true,
                    formatter : validFormatter
                }, {
                    name : 'validationMessage',
                    index : 'validationMessage',
                    width : 200,
                    hidden : false,
                    cellattr: function (rowId, tv, rawObject, cm, rdata) {
                        return 'style="white-space: normal;'
                    }
                }, {
                    name : 'modified',
                    index : 'modified',
                    width : 50,
                    editable: false,
                    edittype: 'checkbox',
                    align: 'center',
                    editoptions: { value:"True:False" },
                    formatter: modifiedFormatter,
                    formatoptions: {disabled: false}
                }, ],
                jsonReader : {
                    page : "page",
                    total : "total",
                    records : "records",
                    root : 'history',
                    repeatitems : false
                },
                gridComplete : function() {
                    for (var i = 0; i < invalidRows.length; i++) {
                        $("#" + invalidRows[i]).find("td").addClass(
                            "ui-state-error");
                    }

                    if("${historyID}" != -1 && !selectRowUsed) {
                        jQuery("#historylist").setSelection("${historyID}", true);
                        selectRowUsed = true;
                    } else {
                        jQuery("#historylist").setSelection(
                        $("#historylist").getDataIDs()[0], true);
                    }
                },
                loadComplete : function() {
                    // this gets/sets a cookie for grid height and makes the grid resizable
                    var initialGridSize = 300;
                    if($.cookie("historyGridHeight") != null) {
                        initialGridSize = $.cookie("historyGridHeight");
                    }

                    jQuery("#historylist").jqGrid('setGridHeight', initialGridSize);

                    // allow grid resize
                    jQuery("#historylist").jqGrid('gridResize',
                    {
                        minHeight:300,
                        maxHeight:1000,
                        stop: function( event, ui ) {
                            console.log(ui.size.height);
                            $.cookie("historyGridHeight", ui.size.height, { expires: 10000, path: '/testproxy/history' });
                        }
                    });

                    // set row height to be a little larger
                    var grid = $("#historylist");
                    var ids = grid.getDataIDs();
                    for (var i = 0; i < ids.length; i++) {
                        grid.setRowData ( ids[i], false, {height: 20+i*2} );
                    }
                },
                onSelectRow : function(id) {
                    var data = jQuery("#historylist").jqGrid('getRowData',
                        id);
                    currentHistoryId = data.id;
                    loadData(data.id);
                },
                rowList : [],
                pager : '#historynavGrid',
                sortname : 'id',
                viewrecords : true,
                sortorder : "desc",
                caption : '<font size="5">History: ${profile_name}</font>'
            });

    historyList.jqGrid('navGrid', '#historynavGrid', {
        edit : false,
        add : false,
        del : false
    }, {}, {}, {});

    function modifiedFormatter( cellvalue, options, rowObject ) {
        var checkedValue = 0;
        if (cellvalue == true) {
            checkedValue = 1;
        }
        var newCellValue = '<input id="modified_' + rowObject.pathId + '"type="checkbox" offval="0" value="' + checkedValue + '"';
        if (checkedValue == 1) {
            newCellValue += 'checked="checked"';
        }
        newCellValue += ' disabled=true>';
        return newCellValue;
    }

    function showPathTester() {
        // map request type
        console.log(historyData);
        console.log(historyData.history.requestType);
        switch(historyData.history.requestType) {
            case 'ALL':
                $('#pathTesterRequestType').val(0);
                break;
            case 'GET':
                $('#pathTesterRequestType').val(1);
                break;
            case 'PUT':
                $('#pathTesterRequestType').val(2);
                break;
            case 'POST':
                $('#pathTesterRequestType').val(3);
                break;
            case 'DELETE':
                $('#pathTesterRequestType').val(4);
                break;
        }

        $('#pathTesterURL').val($("#requestQuery").val() + "?" + $("#requestParameters").val());
        navigatePathTester();
        pathTesterSubmit();
    }

    //http://stackoverflow.com/questions/10655202/detect-multiple-keys-on-single-keypress-event-on-jquery
    //17 = CTRL, 8 = DEL, 46 = Backspace
    var map = {17: false, 8: false, 46: false};
    $(document).keydown(function(e) {
        if (e.keyCode in map) {
            map[e.keyCode] = true;
            if (map[17] && (map[8] || map[46])) {
                clearHistory();
            }
        }
    }).keyup(function(e) {
        if (e.keyCode in map) {
            map[e.keyCode] = false;
        }
    });

    /**
    This is adapted from https://code.google.com/p/google-diff-match-patch/ as instructed in the api documentation
    */
    /**
     * Convert a diff array into a pretty HTML report.
     * @param {!Array.<!diff_match_patch.Diff>} diffs Array of diff tuples.
     * @return {string} HTML representation.
     */
    diff_prettyHtml = function(diffs) {
      var html = [];
      var pattern_amp = /&/g;
      var pattern_lt = /</g;
      var pattern_gt = />/g;
      var pattern_para = /\n/g;
      for (var x = 0; x < diffs.length; x++) {
        var op = diffs[x][0];    // Operation (insert, delete, equal)
        var data = diffs[x][1];  // Text of change.
        var text = data.replace(pattern_amp, '&amp;').replace(pattern_lt, '&lt;')
            .replace(pattern_gt, '&gt;').replace(pattern_para, '<br>');
        switch (op) {
          case DIFF_INSERT:
            html[x] = '<ins style="background:#e6ffe6;">' + text + '</ins>';
            break;
          case DIFF_DELETE:
            html[x] = '<del style="background:#ffe6e6;">' + text + '</del>';
            break;
          case DIFF_EQUAL:
            html[x] = '<span>' + text + '</span>';
            break;
        }
      }
      return html.join('');
    };
</script>
</body>
</html>
