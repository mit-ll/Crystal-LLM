//= require jquery
//  require jquery.turbolinks
//= require jquery_ujs
//= require jquery-ui
//  require jquery-fileupload
//  require jquery-fileupload/basic
//  require jquery-fileupload/vendor/tmpl
//= require dataTables/jquery.dataTables
//= require turbolinks
//  require fullcalendar
//  require openlayers-rails
//  require local_time

//= require highcharts
//= require highcharts/highcharts-more
//  require highcharts/modules/exporting
//  require highcharts/modules/export-data
//  require highcharts/modules/accessibility

//  require highcharts/highstock
//  require highstock

//= require d3
//= require scatter

//  require apexcharts

//  require_tree .


function dataTablesInit(){
    $('.dataTable').dataTable({
        "bJQueryUI": true,
        "pagingType": "full_numbers"
    });
}

$(function(){
    dataTablesInit();
});
