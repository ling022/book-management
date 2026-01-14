<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // 设置请求编码
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    // 每页显示数量
    int pageSize = 9;
    if (request.getAttribute("pageSize") != null) {
        pageSize = (Integer) request.getAttribute("pageSize");
    }

    // 获取应用上下文路径
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        /* 重置和基础样式 */
        * {
            box-sizing: border-box;
        }

        .book-card {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            padding: 15px;
            transition: all 0.3s ease;
            height: 480px;  /* 固定高度，内部滚动 */
            display: flex;
            flex-direction: column;
            position: relative;
            overflow: hidden;  /* 防止内容溢出 */
        }

        .book-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
            border-color: #007bff;
        }

        /* 封面容器 - 固定高度 */
        .book-cover-container {
            height: 160px;
            margin: 0 auto 10px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;  /* 防止压缩 */
        }

        /* 封面图片样式 - 确保完整显示 */
        .book-cover-img {
            max-width: 100%;
            max-height: 100%;
            height: auto;
            width: auto;
            object-fit: contain;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 3px;
            background: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        /* 无封面占位符 */
        .no-cover-placeholder {
            width: 120px;
            height: 140px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px dashed #ccc;
            border-radius: 4px;
            background: #f9f9f9;
            color: #999;
            font-size: 13px;
        }

        /* 图书标题 - 固定高度 */
        .book-title {
            font-size: 15px;
            font-weight: 600;
            color: #007bff;
            margin-bottom: 8px;
            line-height: 1.4;
            height: 40px;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            text-align: center;
            flex-shrink: 0;
        }

        /* 图书信息区域 - 可滚动 */
        .book-info {
            flex: 1;
            overflow-y: auto;  /* 允许垂直滚动 */
            overflow-x: hidden; /* 防止水平滚动 */
            text-align: center;
            padding: 0 5px;
            margin-bottom: 10px;
            border-top: 1px solid #f0f0f0;
            padding-top: 8px;
        }

        .book-info-item {
            margin-bottom: 6px;
            line-height: 1.4;
            font-size: 13px;
            word-wrap: break-word;
            word-break: break-word;
        }

        /* 特别处理分类显示 */
        .category-item {
            min-height: 36px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .category-label {
            color: #555;
            font-weight: 600;
            display: block;
            margin-bottom: 2px;
        }

        .category-text {
            color: #666;
            font-size: 13px;
            line-height: 1.3;
            display: inline-block;
            max-width: 100%;
            word-break: break-all;
        }

        .stock-info {
            font-size: 13px;
        }

        .available {
            color: #28a745;
        }

        .unavailable {
            color: #dc3545;
        }

        .book-status {
            margin-top: 5px;
            margin-bottom: 5px;
            flex-shrink: 0;
        }

        /* 操作按钮区域 - 固定底部 */
        .book-actions {
            margin-top: auto;
            padding-top: 10px;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: center;
            gap: 5px;
            flex-wrap: wrap;
            flex-shrink: 0;
        }

        /* 按钮样式修复 */
        .btn-xs {
            padding: 3px 6px;
            font-size: 11px;
            line-height: 1.2;
            min-width: 50px;
            max-width: 70px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin: 2px;
        }

        /* 搜索面板 */
        .search-panel {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            border: 1px solid #e0e0e0;
        }

        /* 其他样式保持不变 */
        .empty-state {
            text-align: center;
            padding: 50px 20px;
            color: #666;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            margin: 20px 0;
        }

        .empty-state-icon {
            font-size: 48px;
            color: #ccc;
            margin-bottom: 20px;
        }

        .stats-badge {
            background: #e9ecef;
            color: #495057;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            border: 1px solid #dee2e6;
        }

        .label {
            display: inline-block;
            padding: 3px 6px;
            font-size: 11px;
            font-weight: 600;
            line-height: 1;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: 3px;
            margin: 2px;
        }

        .label-success {
            background-color: #28a745;
            color: #fff;
        }

        .label-warning {
            background-color: #ffc107;
            color: #212529;
        }

        .label-danger {
            background-color: #dc3545;
            color: #fff;
        }

        .label-default {
            background-color: #6c757d;
            color: #fff;
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .book-card {
                height: 450px;
            }

            .book-cover-container {
                height: 140px;
            }

            .book-cover-img {
                max-height: 140px;
            }

            .no-cover-placeholder {
                width: 100px;
                height: 120px;
            }

            .btn-xs {
                padding: 2px 4px;
                font-size: 10px;
                min-width: 45px;
            }

            .book-title {
                font-size: 14px;
                height: 38px;
            }
        }

        @media (max-width: 480px) {
            .book-card {
                height: 420px;
            }

            .book-cover-container {
                height: 120px;
            }

            .book-cover-img {
                max-height: 120px;
            }

            .btn-xs {
                padding: 1px 3px;
                font-size: 9px;
                min-width: 40px;
            }
        }

        /* 滚动条样式 */
        .book-info::-webkit-scrollbar {
            width: 4px;
        }

        .book-info::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 2px;
        }

        .book-info::-webkit-scrollbar-thumb {
            background: #ccc;
            border-radius: 2px;
        }

        .book-info::-webkit-scrollbar-thumb:hover {
            background: #aaa;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="book"/>
</jsp:include>

<div class="container">
    <div class="row">
        <div class="col-md-12">
            <h2>图书管理</h2>
        </div>
    </div>

    <!-- 搜索面板 -->
    <div class="search-panel">
        <div class="row">
            <div class="col-md-8">
                <form action="${pageContext.request.contextPath}/book/list" method="get" class="form-inline">
                    <div class="form-group" style="margin-right: 10px;">
                        <input type="text" name="keyword" class="form-control"
                               value="${param.keyword}" placeholder="输入书名、作者或ISBN" style="width: 300px;">
                    </div>
                    <div class="form-group" style="margin-right: 10px;">
                        <input type="text" name="category" class="form-control"
                               value="${param.category}" placeholder="分类" style="width: 150px;">
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <span class="glyphicon glyphicon-search"></span> 搜索
                    </button>
                    <a href="${pageContext.request.contextPath}/book/list" class="btn btn-default">重置</a>
                </form>
            </div>
            <div class="col-md-4 text-right">
                <!-- 只有管理员可以添加图书 -->
                <c:if test="${sessionScope.role == 'ADMIN'}">
                    <a href="${pageContext.request.contextPath}/book/add" class="btn btn-success">
                        <span class="glyphicon glyphicon-plus"></span> 添加图书
                    </a>
                </c:if>
            </div>
        </div>
    </div>

    <!-- 统计信息 -->
    <div class="row" style="margin-bottom: 20px;">
        <div class="col-md-12">
            <span class="stats-badge">共 ${books.size()} 本图书</span>
            <span class="stats-badge">每页 <%= pageSize %> 本</span>
            <c:if test="${not empty param.keyword}">
                <span class="stats-badge">搜索结果</span>
            </c:if>
        </div>
    </div>

    <!-- 图书列表 -->
    <div class="row" id="bookList">
        <c:choose>
            <c:when test="${not empty books && !books.isEmpty()}">
                <c:forEach items="${books}" var="book">
                    <div class="col-lg-4 col-md-4 col-sm-6 col-xs-12">
                        <div class="book-card">
                            <!-- 图书封面 -->
                            <div class="book-cover-container">
                                <c:choose>
                                    <c:when test="${not empty book.imagePath}">
                                        <!-- 修复图片路径 -->
                                        <img src="<%= contextPath %>${book.imagePath}"
                                             alt="${book.title}"
                                             class="book-cover-img"
                                             onerror="handleImageError(this, ${book.id})">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="no-cover-placeholder">
                                            <span>暂无封面</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- 图书标题 -->
                            <div class="book-title">${book.title}</div>

                            <!-- 图书信息 -->
                            <div class="book-info">
                                <div class="book-info-item">
                                    <strong>作者：</strong>${book.author}
                                </div>
                                <div class="book-info-item">
                                    <strong>ISBN：</strong>${book.isbn}
                                </div>

                                <!-- 分类显示 -->
                                <div class="book-info-item category-item">
                                    <span class="category-label">分类：</span>
                                    <span class="category-text">
                                        <c:choose>
                                            <c:when test="${not empty book.category}">
                                                ${book.category}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">未分类</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="book-info-item stock-info">
                                    <strong>库存：</strong>
                                    <span class="${book.availableCopies > 0 ? 'available' : 'unavailable'}">
                                        ${book.availableCopies}/${book.totalCopies} 册
                                    </span>
                                </div>
                                <div class="book-info-item book-status">
                                    <c:choose>
                                        <c:when test="${book.status == 'AVAILABLE'}">
                                            <span class="label label-success">可借</span>
                                        </c:when>
                                        <c:when test="${book.status == 'BORROWED'}">
                                            <span class="label label-warning">已借出</span>
                                        </c:when>
                                        <c:when test="${book.status == 'MAINTENANCE'}">
                                            <span class="label label-danger">维护中</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="label label-default">${book.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- 操作按钮 -->
                            <div class="book-actions">
                                <!-- 详情按钮 -->
                                <a href="${pageContext.request.contextPath}/book/detail/${book.id}"
                                   class="btn btn-info btn-xs" title="查看详情">
                                    <span class="glyphicon glyphicon-eye-open"></span> 详情
                                </a>

                                <!-- 编辑和删除按钮 - 仅管理员可见 -->
                                <c:if test="${sessionScope.role == 'ADMIN'}">
                                    <a href="${pageContext.request.contextPath}/book/edit/${book.id}"
                                       class="btn btn-warning btn-xs" title="编辑图书">
                                        <span class="glyphicon glyphicon-edit"></span> 编辑
                                    </a>
                                    <a href="javascript:void(0);"
                                       class="btn btn-danger btn-xs delete-book"
                                       data-id="${book.id}"
                                       data-title="${book.title}"
                                       title="删除图书">
                                        <span class="glyphicon glyphicon-trash"></span> 删除
                                    </a>
                                </c:if>

                                <!-- 借阅按钮 - 普通用户可以借阅，且图书状态不是维护中 -->
                                <c:if test="${book.availableCopies > 0 && book.status != 'MAINTENANCE' && sessionScope.role == 'USER'}">
                                    <a href="${pageContext.request.contextPath}/borrow/add?bookId=${book.id}&preselect=true&title=${book.title}"
                                       class="btn btn-success btn-xs" title="借阅此书">
                                        <span class="glyphicon glyphicon-book"></span> 借阅
                                    </a>
                                </c:if>

                                <!-- 如果图书维护中，显示提示 -->
                                <c:if test="${book.status == 'MAINTENANCE'}">
                                    <button class="btn btn-secondary btn-xs" disabled title="图书维护中">
                                        <span class="glyphicon glyphicon-wrench"></span> 维护中
                                    </button>
                                </c:if>

                                <!-- 如果不可借，显示原因 -->
                                <c:if test="${book.availableCopies == 0 && book.status != 'MAINTENANCE' && sessionScope.role == 'USER'}">
                                    <button class="btn btn-secondary btn-xs" disabled title="已全部借出">
                                        <span class="glyphicon glyphicon-ban-circle"></span> 已借完
                                    </button>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-md-12">
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <span class="glyphicon glyphicon-book"></span>
                        </div>
                        <h4>暂无图书数据</h4>
                        <p>系统中还没有图书，或者搜索结果为空。</p>
                        <c:if test="${sessionScope.role == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/book/add" class="btn btn-primary">
                                <span class="glyphicon glyphicon-plus"></span> 添加第一本图书
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- 分页 -->
    <c:if test="${totalPages > 1}">
        <nav aria-label="Page navigation" style="margin-top: 30px;">
            <ul class="pagination">
                <li class="${currentPage == 1 ? 'disabled' : ''}">
                    <a href="${pageContext.request.contextPath}/book/list?page=${currentPage - 1}&keyword=${param.keyword}&category=${param.category}"
                       aria-label="Previous">
                        <span aria-hidden="true">&laquo;</span>
                    </a>
                </li>

                <c:forEach begin="1" end="${totalPages}" var="page">
                    <li class="${page == currentPage ? 'active' : ''}">
                        <a href="${pageContext.request.contextPath}/book/list?page=${page}&keyword=${param.keyword}&category=${param.category}">
                                ${page}
                        </a>
                    </li>
                </c:forEach>

                <li class="${currentPage == totalPages ? 'disabled' : ''}">
                    <a href="${pageContext.request.contextPath}/book/list?page=${currentPage + 1}&keyword=${param.keyword}&category=${param.category}"
                       aria-label="Next">
                        <span aria-hidden="true">&raquo;</span>
                    </a>
                </li>
            </ul>
        </nav>
    </c:if>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    // 图片错误处理函数
    function handleImageError(img, bookId) {
        console.log('图片加载失败 - 图书ID:', bookId, '图片路径:', img.src);

        // 先移除onerror事件，防止循环
        img.onerror = null;

        // 替换为默认封面图片
        var defaultImg = '<%= contextPath %>/static/images/no-cover.png';
        img.src = defaultImg;
        img.className = 'book-cover-img';

        // 设置新的onerror处理
        img.onerror = function() {
            this.onerror = null;
            showNoCoverPlaceholder(this, bookId);
        };
    }

    // 显示无封面占位符
    function showNoCoverPlaceholder(img, bookId) {
        console.log('显示占位符 - 图书ID:', bookId);
        var container = img.parentElement;
        if (container && container.className === 'book-cover-container') {
            container.innerHTML = '<div class="no-cover-placeholder"><span>暂无封面</span></div>';
        }
    }

    // 删除图书
    $(document).on('click', '.delete-book', function(e) {
        e.stopPropagation();
        var bookId = $(this).data('id');
        var bookTitle = $(this).data('title');

        if (confirm('确定要删除《' + bookTitle + '》吗？此操作不可恢复！')) {
            $.ajax({
                url: '<%= contextPath %>/book/delete/' + bookId,
                type: 'GET',
                dataType: 'json',
                success: function(result) {
                    if (result.success) {
                        alert(result.successMessage);
                        // 刷新页面
                        location.reload();
                    } else {
                        alert(result.errorMessage);
                    }
                },
                error: function(xhr, status, error) {
                    alert('删除失败: ' + error);
                }
            });
        }
    });

    // 页面加载时初始化
    $(document).ready(function() {
        console.log('页面加载完成，检查图书卡片...');

        // 检查每个卡片的高度
        $('.book-card').each(function(index) {
            var $card = $(this);
            var actualHeight = $card.height();
            var contentHeight = $card.find('.book-info').prop('scrollHeight');

            console.log('卡片' + (index + 1) + ': 实际高度=' + actualHeight + 'px, 内容高度=' + contentHeight + 'px');

            // 如果内容太多，显示滚动条提示
            if (contentHeight > 200) {
                $card.find('.book-info').css('border', '1px solid #e0e0e0');
            }
        });

        // 检查所有图片
        $('.book-cover-img').each(function(index) {
            var $img = $(this);
            var src = $img.attr('src');

            if (src && src.indexOf('no-cover.png') === -1) {
                // 预加载检查
                var testImg = new Image();
                testImg.onload = function() {
                    console.log('图片' + (index + 1) + '加载成功');
                };
                testImg.onerror = function() {
                    console.log('图片' + (index + 1) + '加载失败:', src);
                    $img.trigger('error');
                };
                testImg.src = src;
            }
        });
    });
</script>
</body>
</html>