<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    // 设置请求编码（备份，Spring过滤器应该已经处理）
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>添加图书</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .add-form-container {
            max-width: 800px;
            margin: 0 auto;
        }
        .form-section {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .form-section h4 {
            color: #333;
            border-bottom: 2px solid #28a745;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .form-hint {
            font-size: 13px;
            color: #6c757d;
            margin-top: 5px;
        }
        .required-star {
            color: #dc3545;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="book"/>
</jsp:include>

<div class="container">
    <div class="add-form-container">
        <h2>添加新图书</h2>

        <!-- 权限检查 -->
        <c:if test="${sessionScope.role != 'ADMIN'}">
            <div class="form-section">
                <div class="alert alert-danger">
                    <strong>权限不足！</strong> 只有管理员可以添加图书。
                </div>
                <a href="${pageContext.request.contextPath}/book/list" class="btn btn-default">
                    <span class="glyphicon glyphicon-arrow-left"></span> 返回列表
                </a>
            </div>
        </c:if>

        <c:if test="${sessionScope.role == 'ADMIN'}">
            <form action="${pageContext.request.contextPath}/book/add" method="post" id="addBookForm">
                <div class="form-section">
                    <h4>基本信息</h4>

                    <div class="form-group">
                        <label for="title">
                            书名 <span class="required-star">*</span>
                        </label>
                        <input type="text" class="form-control" id="title" name="title"
                               placeholder="请输入图书名称" required maxlength="200">
                        <div class="form-hint">请输入完整的图书名称</div>
                    </div>

                    <div class="form-group">
                        <label for="author">
                            作者 <span class="required-star">*</span>
                        </label>
                        <input type="text" class="form-control" id="author" name="author"
                               placeholder="请输入作者姓名" required maxlength="100">
                        <div class="form-hint">请输入作者姓名</div>
                    </div>

                    <div class="form-group">
                        <label for="isbn">
                            ISBN <span class="required-star">*</span>
                        </label>
                        <input type="text" class="form-control" id="isbn" name="isbn"
                               placeholder="请输入ISBN号" required maxlength="50">
                        <div class="form-hint">国际标准书号，用于唯一标识图书</div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="publisher">出版社</label>
                                <input type="text" class="form-control" id="publisher" name="publisher"
                                       placeholder="请输入出版社" maxlength="100">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="publishDate">出版日期</label>
                                <input type="date" class="form-control" id="publishDate"
                                       name="publishDateStr">
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="category">分类</label>
                        <input type="text" class="form-control" id="category" name="category"
                               placeholder="例如：小说、计算机、历史等" maxlength="50">
                        <div class="form-hint">图书分类，便于管理和检索</div>
                    </div>

                    <div class="form-group">
                        <label for="description">描述</label>
                        <textarea class="form-control" id="description" name="description"
                                  rows="4" placeholder="可输入图书简介、内容提要等信息"
                                  maxlength="1000"></textarea>
                    </div>
                </div>
                <div class="form-section">
                    <h4>图书封面</h4>

                    <div class="form-group">
                        <label for="imageFile">上传封面图片</label>
                        <input type="file" class="form-control" id="imageFile" name="imageFile"
                               accept="image/jpeg,image/png,image/gif,image/bmp">
                        <div class="form-hint">支持jpg、png、gif、bmp格式，大小不超过5MB</div>
                    </div>

                    <!-- 图片预览 -->
                    <div class="preview-container" id="previewContainer" style="display: none;">
                        <h5>封面预览:</h5>
                        <img id="previewImage" style="max-width: 200px; max-height: 300px;">
                    </div>
                </div>
                <div class="form-section">
                    <h4>库存信息</h4>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="totalCopies">
                                    总册数 <span class="required-star">*</span>
                                </label>
                                <input type="number" class="form-control" id="totalCopies"
                                       name="totalCopies" value="1"
                                       min="1" max="1000" required>
                                <div class="form-hint">图书馆拥有的该书总数量</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="availableCopies">
                                    可借册数 <span class="required-star">*</span>
                                </label>
                                <input type="number" class="form-control" id="availableCopies"
                                       name="availableCopies" value="1"
                                       min="0" max="1000" required>
                                <div class="form-hint">当前可借出的数量</div>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="status">
                            状态 <span class="required-star">*</span>
                        </label>
                        <select class="form-control" id="status" name="status" required>
                            <option value="AVAILABLE" selected>可借</option>
                            <option value="BORROWED">已借出</option>
                            <option value="MAINTENANCE">维护中</option>
                        </select>
                        <div class="form-hint">当前图书的流通状态</div>
                    </div>
                </div>

                <div class="form-section" style="text-align: center;">
                    <button type="submit" class="btn btn-success btn-lg">
                        <span class="glyphicon glyphicon-plus"></span> 添加图书
                    </button>
                    <a href="${pageContext.request.contextPath}/book/list"
                       class="btn btn-default btn-lg">
                        <span class="glyphicon glyphicon-remove"></span> 取消
                    </a>
                </div>
            </form>
        </c:if>
    </div>
</div>

<jsp:include page="../footer.jsp"/>

<script>
    $(document).ready(function() {
        // 表单验证
        $('form').submit(function() {
            var totalCopies = parseInt($('#totalCopies').val());
            var availableCopies = parseInt($('#availableCopies').val());

            if (availableCopies > totalCopies) {
                alert('可借册数不能大于总册数！');
                $('#availableCopies').focus();
                return false;
            }

            if (availableCopies < 0) {
                alert('可借册数不能为负数！');
                $('#availableCopies').focus();
                return false;
            }

            return true;
        });

        // 动态设置可借册数最大值
        $('#totalCopies').on('change', function() {
            var total = parseInt($(this).val());
            $('#availableCopies').attr('max', total);

            var currentAvailable = parseInt($('#availableCopies').val());
            if (currentAvailable > total) {
                $('#availableCopies').val(total);
            }
        });
        $('#imageFile').change(function() {
            var file = this.files[0];
            if (file) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    $('#previewContainer').show();
                    $('#previewImage').attr('src', e.target.result);
                }
                reader.readAsDataURL(file);
            } else {
                $('#previewContainer').hide();
            }
        });

        // 修改表单提交方式（需要enctype）
        $('#addBookForm').attr('enctype', 'multipart/form-data');
    });
</script>
</body>
</html>