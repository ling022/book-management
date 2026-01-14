<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>数据统计 - 图书管理系统</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <!-- 引入ECharts -->
    <script src="https://cdn.bootcdn.net/ajax/libs/echarts/5.4.2/echarts.min.js"></script>
    <style>
        .chart-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .stat-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #1890ff;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
            margin-top: 10px;
        }
        .chart-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #333;
            border-left: 4px solid #1890ff;
            padding-left: 10px;
        }
        .loading {
            text-align: center;
            padding: 50px;
            color: #999;
        }
    </style>
</head>
<body>
<jsp:include page="common.jsp">
    <jsp:param name="page" value="statistics"/>
</jsp:include>

<div class="container">
    <h2>数据统计</h2>

    <!-- 统计卡片 -->
    <div class="row" id="statCards">
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-number" id="totalBorrows">0</div>
                <div class="stat-label">总借阅次数</div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-number" id="currentBorrowing">0</div>
                <div class="stat-label">当前借阅中</div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-number" id="overdueCount">0</div>
                <div class="stat-label">逾期数量</div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card">
                <div class="stat-number" id="returnRate">0%</div>
                <div class="stat-label">归还率</div>
            </div>
        </div>
    </div>

    <!-- 借阅趋势图表 -->
    <div class="chart-container">
        <div class="chart-title">借阅趋势分析</div>
        <div id="borrowChart" style="width: 100%; height: 400px;">
            <div class="loading">
                <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
                <p>正在加载图表...</p>
            </div>
        </div>
    </div>

    <!-- 图书分类统计 -->
    <div class="row">
        <div class="col-md-6">
            <div class="chart-container">
                <div class="chart-title">图书分类统计</div>
                <div id="categoryChart" style="width: 100%; height: 300px;">
                    <div class="loading">
                        <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
                        <p>正在加载图表...</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="chart-container">
                <div class="chart-title">热门借阅图书</div>
                <div id="popularBooks" style="padding: 20px;">
                    <div class="loading">
                        <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
                        <p>正在加载数据...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>

<script>
    $(document).ready(function() {
        // 加载实时统计数据
        loadStatisticsCards();
        loadBorrowTrendChart();
        loadCategoryChart();
        loadPopularBooks();
    });

    // 1. 加载统计卡片
    function loadStatisticsCards() {
        $.ajax({
            url: '${pageContext.request.contextPath}/statistics/statistics',
            type: 'GET',
            dataType: 'json',
            success: function(result) {
                if (result.success) {
                    updateStatisticsCards(result);
                }
            }
        });
    }

    // 更新统计卡片
    function updateStatisticsCards(data) {
        $('#totalBorrows').text(data.totalBorrows || 0);
        $('#currentBorrowing').text(data.currentBorrows || 0);
        $('#overdueCount').text(data.overdueCount || 0);
        $('#returnRate').text(data.returnRate || '0.0%');
    }

    // 2. 加载借阅趋势图表
    function loadBorrowTrendChart() {
        $.ajax({
            url: '${pageContext.request.contextPath}/statistics/all?days=30',
            type: 'GET',
            dataType: 'json',
            success: function(result) {
                if (result.success && result.trendData) {
                    renderBorrowChart(result.trendData);
                }
            }
        });
    }

    // 渲染借阅趋势图表
    function renderBorrowChart(trendData) {
        if (!trendData || trendData.length === 0) return;

        var dates = [];
        var counts = [];

        trendData.forEach(function(item) {
            dates.push(item.date);
            counts.push(item.count);
        });

        var chart = echarts.init(document.getElementById('borrowChart'));
        var option = {
            title: { text: '最近30天借阅趋势', left: 'center' },
            tooltip: { trigger: 'axis' },
            xAxis: {
                type: 'category',
                data: dates,
                axisLabel: { rotate: 45 }
            },
            yAxis: { type: 'value', name: '借阅数量' },
            series: [{
                name: '借阅数量',
                type: 'line',
                data: counts,
                smooth: true
            }]
        };

        chart.setOption(option);
        $(window).on('resize', function() { chart.resize(); });
    }

    // 3. 加载图书分类图表
    function loadCategoryChart() {
        $.ajax({
            url: '${pageContext.request.contextPath}/statistics/all',
            type: 'GET',
            dataType: 'json',
            success: function(result) {
                if (result.success && result.bookStats && result.bookStats.categoryStats) {
                    renderCategoryChart(result.bookStats);
                }
            }
        });
    }

    // 渲染图书分类图表
    function renderCategoryChart(bookStats) {
        var categoryData = bookStats.categoryStats;
        if (!categoryData) return;

        var chartData = [];
        for (var category in categoryData) {
            if (categoryData.hasOwnProperty(category)) {
                chartData.push({
                    name: category,
                    value: categoryData[category]
                });
            }
        }

        var chart = echarts.init(document.getElementById('categoryChart'));
        var option = {
            title: { text: '图书分类统计', left: 'center' },
            tooltip: { trigger: 'item' },
            legend: { orient: 'vertical', left: 'left' },
            series: [{
                name: '图书分类',
                type: 'pie',
                radius: ['40%', '70%'],
                center: ['60%', '50%'],
                data: chartData
            }]
        };

        chart.setOption(option);
        $(window).on('resize', function() { chart.resize(); });
    }

    // 4. 加载热门图书
    function loadPopularBooks() {
        $.ajax({
            url: '${pageContext.request.contextPath}/statistics/all',
            type: 'GET',
            dataType: 'json',
            success: function(result) {
                if (result.success && result.popularBooks) {
                    renderPopularBooks(result.popularBooks);
                }
            }
        });
    }

    // 渲染热门图书
    function renderPopularBooks(books) {
        if (!books || books.length === 0) return;

        // 排序
        books.sort(function(a, b) {
            return (b.borrowCount || 0) - (a.borrowCount || 0);
        });

        var html = '<div class="table-responsive">';
        html += '<table class="table table-hover table-striped">';
        html += '<thead><tr>';
        html += '<th>排名</th><th>图书名称</th><th>作者</th><th>借阅次数</th>';
        html += '</tr></thead><tbody>';

        var displayCount = Math.min(5, books.length);
        for (var i = 0; i < displayCount; i++) {
            var book = books[i];
            html += '<tr>';
            html += '<td>' + (i + 1) + '</td>';
            html += '<td>' + (book.title || '未知图书') + '</td>';
            html += '<td>' + (book.author || '未知作者') + '</td>';
            html += '<td>' + (book.borrowCount || 0) + '</td>';
            html += '</tr>';
        }

        html += '</tbody></table></div>';
        $('#popularBooks').html(html);
    }

    // 5. 全局刷新函数（可选）
    function refreshAllStatistics() {
        loadStatisticsCards();
        loadBorrowTrendChart();
        loadCategoryChart();
        loadPopularBooks();
    }
</script>
</body>
</html>