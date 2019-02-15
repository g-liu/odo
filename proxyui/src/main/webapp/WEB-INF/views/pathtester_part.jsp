<script type="text/javascript">
'use strict';
function pathTesterSubmit() {
    var url = $('#pathTesterURL').val();
    var requestType = $('#pathTesterRequestType').val();
    var encoded = encodeURIComponent(url);

    $.ajax({
        type:"GET",
        url: '<c:url value="/api/path/test"/>',
        data: 'profileIdentifier=${profile_id}&requestType=' + requestType + '&url=' + encoded,
        success: function(data) {
            data = $.parseJSON(data);
            $("#pathTesterResults").empty();

            if (data.paths.length === 0) {
                $("#pathTesterResults").text("No matching path found.");
                return;
            }

            var $pathTable = $("<table>")
                .addClass("paddedtable")
                .attr("id", "pathTesterTable")
                .append($("<tr>")
                    .append($("<td>").addClass("ui-widget-header").text("#"))
                    .append($("<td>").addClass("ui-widget-header").text("Path Name"))
                    .append($("<td>").addClass("ui-widget-header").text("Path"))
                    .append($("<td>").addClass("ui-widget-header").text("Global")));

            jQuery.each(data.paths, function(index, value) {
                $pathTable
                    .append($("<tr>")
                        .append($("<td>").addClass("ui-widget-content").text(index + 1))
                        .append($("<td>").addClass("ui-widget-content").text(value.pathName))
                        .append($("<td>").addClass("ui-widget-content").text(value.path))
                        .append($("<td>").addClass("ui-widget-content").text(value.global)));
            });

            $("#pathTesterResults").append($pathTable);
        },
        error: function(xhr) {
            // TODO: Don't leave this blank!
        }
    });
}

function navigatePathTester() {
    $("#pathTesterDialog").dialog({
        title: "Path Tester",
        width: 750,
        modal: true,
        buttons: {
            "Close": function() {
                $("#pathTesterDialog").dialog("close");
            }
        }
    });
}
</script>

<!-- Hidden div for path tester -->
<div id="pathTesterDialog" style="display:none;">
    <table>
        <tr>
            <td>
                <label for="pathTesterURL">URL to Test:</label>
                <input id="pathTesterURL" size=45 />
            </td>
            <td>
                <select id="pathTesterRequestType" class="form-control" style="width:auto;">
                    <option value="0">ALL</option>
                    <option value="1">GET</option>
                    <option value="2">PUT</option>
                    <option value="3">POST</option>
                    <option value="4">DELETE</option>
                </select>
            </td>
            <td>
                <button class="btn btn-primary" onclick="pathTesterSubmit()">Test</button>
            </td>
        </tr>
    </table>
    <div class="ui-widget">
        <div class="ui-state-highlight ui-corner-all">
            <p><span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>
            <strong>NOTE:</strong> POST body filters are not taken into account during this test.</p>
        </div>
    </div>
    <div id="pathTesterResults"></div>
</div><!-- /#pathTesterDialog -->
