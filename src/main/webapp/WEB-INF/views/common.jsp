<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getParameter("page");
    if (currentPage == null) {
        currentPage = "";
    }

    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    boolean isAdmin = "ADMIN".equals(role);
    boolean isUser = "USER".equals(role);
    boolean isLoggedIn = username != null && !username.isEmpty();

    // 从请求属性中获取消息（Flash属性会自动转移到请求属性中）
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String infoMessage = (String) request.getAttribute("infoMessage");

    // 如果没有从请求属性中获取到，尝试从session中获取（兼容性处理）
    if (successMessage == null) {
        successMessage = (String) session.getAttribute("successMessage");
        session.removeAttribute("successMessage");
    }
    if (errorMessage == null) {
        errorMessage = (String) session.getAttribute("errorMessage");
        session.removeAttribute("errorMessage");
    }
    if (infoMessage == null) {
        infoMessage = (String) session.getAttribute("infoMessage");
        session.removeAttribute("infoMessage");
    }

    // ====== 新增：资源加载控制 ======
    Boolean resourcesLoaded = (Boolean) session.getAttribute("resourcesLoaded");
    boolean isFirstLoad = resourcesLoaded == null || !resourcesLoaded;
    if (isFirstLoad) {
        session.setAttribute("resourcesLoaded", true);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图书管理系统</title>

    <!-- 所有页面都加载完整CSS -->
    <link href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/3.4.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">

    <style>
        /* 只禁用动画效果 */
        * {
            transition: none !important;
            animation: none !important;
        }

        /* 简化导航栏 */
        .navbar {
            min-height: 50px !important;
        }

        .navbar-nav > li > a {
            padding: 15px 10px !important;
        }
    </style>
</head>
<body>
<!-- 固定位置的消息提示 -->
<div class="message-container" id="messageContainer">
    <!-- 消息会通过JavaScript动态添加到这里 -->
</div>

<!-- 导航栏 -->
<nav class="navbar navbar-inverse navbar-fixed-top">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse"
                    data-target="#navbar" aria-expanded="false">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                图书管理系统
            </a>
        </div>

        <div class="collapse navbar-collapse" id="navbar">
            <ul class="nav navbar-nav">
                <li class="<%= "index".equals(currentPage) ? "active" : "" %>">
                    <a href="${pageContext.request.contextPath}/" class="ajax-link">首页</a>
                </li>

                <% if (isLoggedIn) { %>
                <!-- 登录后根据角色显示 -->
                <li class="<%= "book".equals(currentPage) ? "active" : "" %>">
                    <% if (isAdmin) { %>
                    <a href="${pageContext.request.contextPath}/book/list" class="ajax-link">图书管理</a>
                    <% } else if (isUser) { %>
                    <a href="${pageContext.request.contextPath}/book/list" class="ajax-link">查看图书</a>
                    <% } %>
                </li>
                <li class="<%= "borrow".equals(currentPage) ? "active" : "" %>">
                    <% if (isAdmin) { %>
                    <a href="${pageContext.request.contextPath}/borrow/list" class="ajax-link">借阅管理</a>
                    <% } else if (isUser) { %>
                    <a href="${pageContext.request.contextPath}/borrow/list" class="ajax-link">我的借阅</a>
                    <% } %>
                </li>

                <!-- 只有管理员能看到用户管理 -->
                <% if (isAdmin) { %>
                <li class="<%= "user".equals(currentPage) ? "active" : "" %>">
                    <a href="${pageContext.request.contextPath}/user/list" class="ajax-link">用户管理</a>
                </li>
                <li class="<%= "statistics".equals(currentPage) ? "active" : "" %>">
                    <a href="${pageContext.request.contextPath}/statistics" class="ajax-link">数据统计</a>
                </li>
                <!-- 管理员数据导出 -->
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        数据导出 <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a href="${pageContext.request.contextPath}/export/users">导出用户信息</a></li>
                        <li><a href="${pageContext.request.contextPath}/export/borrows">导出借阅信息</a></li>
                        <li><a href="${pageContext.request.contextPath}/export/books">导出图书信息</a></li>
                    </ul>
                </li>
                <% } %>

                <% } else { %>
                <!-- 未登录时显示公共链接 -->
                <li class="<%= "book".equals(currentPage) ? "active" : "" %>">
                    <a href="${pageContext.request.contextPath}/book/list" class="ajax-link">浏览图书</a>
                </li>
                <% } %>
            </ul>

            <!-- 右侧用户相关保持不变 -->
            <ul class="nav navbar-nav navbar-right">
                <% if (!isLoggedIn) { %>
                <li>
                    <a href="${pageContext.request.contextPath}/user/login" class="ajax-link">
                        <span class="glyphicon glyphicon-log-in"></span> 登录
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/user/register" class="ajax-link">
                        <span class="glyphicon glyphicon-user"></span> 注册
                    </a>
                </li>
                <% } else { %>
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <span class="glyphicon glyphicon-user"></span>
                        <%= username %>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li>
                            <a href="${pageContext.request.contextPath}/user/profile" class="ajax-link">
                                <span class="glyphicon glyphicon-cog"></span> 个人中心
                            </a>
                        </li>
                        <li role="separator" class="divider"></li>
                        <li>
                            <a href="${pageContext.request.contextPath}/user/logout">
                                <span class="glyphicon glyphicon-log-out"></span> 退出登录
                            </a>
                        </li>
                    </ul>
                </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<!-- 主要内容区域 -->
<div class="container" id="main-content">
    <!-- 页面内容会在这里动态加载 -->
</div>

<% if (isFirstLoad) { %>
<!-- 只在第一次加载时引入JavaScript -->
<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
<script src="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/3.4.1/js/bootstrap.min.js"></script>
<% } else { %>
<!-- 后续页面使用内联的jQuery精简版 -->
<script>
    // 简化版jQuery功能
    window.$ = window.jQuery = function(selector) {
        var elements = selector === document ? [document] :
            selector === window ? [window] :
                selector.startsWith('#') ? [document.getElementById(selector.substring(1))] :
                    document.querySelectorAll(selector);

        return {
            html: function(content) {
                if (content === undefined) return elements[0]?.innerHTML;
                elements.forEach(el => el.innerHTML = content);
                return this;
            },
            on: function(event, handler) {
                elements.forEach(el => el.addEventListener(event, handler));
                return this;
            },
            click: function(handler) {
                return this.on('click', handler);
            },
            find: function(selector) {
                var found = [];
                elements.forEach(el => {
                    var results = el.querySelectorAll(selector);
                    results.forEach(r => found.push(r));
                });
                return $(found);
            },
            fadeOut: function(time, callback) {
                elements.forEach(el => {
                    el.style.transition = 'opacity ' + (time || 100) + 'ms';
                    el.style.opacity = 0;
                });
                setTimeout(callback, time || 100);
                return this;
            },
            fadeIn: function(time, callback) {
                elements.forEach(el => {
                    el.style.transition = 'opacity ' + (time || 100) + 'ms';
                    el.style.opacity = 1;
                });
                setTimeout(callback, time || 100);
                return this;
            },
            load: function(url, callback) {
                fetch(url)
                    .then(response => response.text())
                    .then(html => {
                        this.html(html);
                        if (callback) callback();
                    });
                return this;
            }
        };
    };

    // 简化版AJAX
    $.ajax = function(options) {
        fetch(options.url, {
            method: options.type || 'GET',
            body: options.data
        })
            .then(response => response.json())
            .then(options.success)
            .catch(options.error);
    };

    $.get = function(url, success) {
        fetch(url)
            .then(response => response.text())
            .then(success);
    };

    $.post = function(url, data, success) {
        fetch(url, {
            method: 'POST',
            body: data,
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        })
            .then(response => response.text())
            .then(success);
    };
</script>
<% } %>

<script>
    // ====== 核心优化代码 ======
    $(document).ready(function() {
        // 1. 缓存页面内容
        var pageCache = {};

        // 2. 当前页面URL
        var currentUrl = window.location.pathname + window.location.search;

        // 3. 初始加载当前页面内容
        if (pageCache[currentUrl]) {
            $('#main-content').html(pageCache[currentUrl]);
        } else {
            loadPageContent(currentUrl, true);
        }

        // 4. 优化消息显示函数
        function showMessage(type, message) {
            if (!message || message.trim() === '') return;

            var alertClass = '';
            var iconClass = '';

            switch(type) {
                case 'success':
                    alertClass = 'alert-success';
                    iconClass = 'glyphicon-ok-sign';
                    break;
                case 'error':
                    alertClass = 'alert-danger';
                    iconClass = 'glyphicon-exclamation-sign';
                    break;
                case 'info':
                    alertClass = 'alert-info';
                    iconClass = 'glyphicon-info-sign';
                    break;
            }

            var messageHtml =
                '<div class="alert alert-message ' + alertClass + '">' +
                '   <span class="glyphicon ' + iconClass + '"></span> ' +
                '   ' + message +
                '</div>';

            $('#messageContainer').html(messageHtml);

            // 3秒后自动关闭
            setTimeout(function() {
                $('.alert-message').fadeOut(300, function() {
                    $(this).remove();
                });
            }, 3000);
        }

        // 5. 检查并显示页面加载时的消息
        <% if (successMessage != null && !successMessage.trim().isEmpty()) { %>
        showMessage('success', '<%= successMessage.replace("'", "\\'").replace("\n", " ") %>');
        <% } %>

        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
        showMessage('error', '<%= errorMessage.replace("'", "\\'").replace("\n", " ") %>');
        <% } %>

        <% if (infoMessage != null && !infoMessage.trim().isEmpty()) { %>
        showMessage('info', '<%= infoMessage.replace("'", "\\'").replace("\n", " ") %>');
        <% } %>

        // 6. AJAX页面加载函数（核心优化）
        function loadPageContent(url, isInitial) {
            // 如果是首页，确保加载完整资源
            if (url === '/' || url === '/index' || url.includes('login') || url.includes('logout')) {
                window.location.href = url;
                return;
            }

            if (!isInitial) {
                $('#main-content').fadeTo(50, 0.7);
            }

            $.get(url + (url.includes('?') ? '&' : '?') + 'ajax=true', function(data) {
                if (isInitial) {
                    $('#main-content').html(data);
                } else {
                    $('#main-content').html(data).fadeTo(100, 1);
                }

                // 缓存页面内容
                pageCache[url] = data;

                // 更新浏览器地址栏（无刷新）
                if (!isInitial && url !== window.location.pathname + window.location.search) {
                    window.history.pushState({url: url}, '', url);
                }
            }).fail(function() {
                // AJAX失败，回退到正常跳转
                window.location.href = url;
            });
        }

        // 7. 绑定链接点击事件 - 排除用户管理页面
        $(document).on('click', '.ajax-link', function(e) {
            e.preventDefault();
            var url = $(this).attr('href');

            // ====== 新增：如果是用户管理页面，正常跳转 ======
            if (url.includes('/user/')) {
                window.location.href = url;
                return;
            }

            // 检查缓存
            if (pageCache[url]) {
                $('#main-content').html(pageCache[url]);
                window.history.pushState({url: url}, '', url);
            } else {
                loadPageContent(url, false);
            }
        });

        // 8. 处理浏览器前进/后退
        window.onpopstate = function(event) {
            if (event.state && event.state.url) {
                if (pageCache[event.state.url]) {
                    $('#main-content').html(pageCache[event.state.url]);
                } else {
                    loadPageContent(event.state.url, false);
                }
            }
        };

        // 9. 表单提交优化
        /*$(document).on('submit', 'form', function(e) {
            var form = $(this);
            var action = form.attr('action');
            var method = form.attr('method') || 'POST';

            var formId = form.attr('id') || '';
            var excludedForms = ['passwordForm']; // 密码修改表单

            // 如果是这些表单，正常提交
            if (excludedForms.includes(formId)) {
                return true;
            }

            // 如果是GET请求或没有action，正常提交
            if (!action || method === 'GET') {
                return true;
            }

            e.preventDefault();

            // 使用AJAX提交表单
            $.ajax({
                url: action,
                type: method,
                data: form.serialize(),
                success: function(response) {
                    // 解析响应中的消息
                    try {
                        var data = JSON.parse(response);
                        if (data.successMessage) {
                            showMessage('success', data.successMessage);
                        }
                        if (data.errorMessage) {
                            showMessage('error', data.errorMessage);
                        }
                        if (data.redirectUrl) {
                            loadPageContent(data.redirectUrl, false);
                        }
                    } catch (e) {
                        // 不是JSON，直接显示为HTML
                        $('#main-content').html(response);
                    }
                },
                error: function() {
                    // AJAX失败时，回退到正常提交
                    form.off('submit').submit();
                }
            });
        });
    });*/
</script>
</body>
</html>