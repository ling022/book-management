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
    <title>编辑图书</title>
    <link href="${pageContext.request.contextPath}/static/css/style.css" rel="stylesheet">
    <style>
        .edit-form-container {
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
            border-bottom: 2px solid #007bff;
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
        .image-preview {
            text-align: center;
            margin: 15px 0;
        }
        .image-preview img {
            max-width: 200px;
            max-height: 300px;
            border: 2px solid #ddd;
            border-radius: 5px;
            padding: 5px;
            background: #fff;
        }
        .no-image-placeholder {
            width: 200px;
            height: 300px;
            border: 2px dashed #ccc;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #999;
            font-size: 16px;
            margin: 0 auto;
            border-radius: 5px;
            background: #f9f9f9;
        }
        .preview-container {
            display: none;
            text-align: center;
            margin: 15px 0;
            padding: 15px;
            border: 1px dashed #007bff;
            border-radius: 5px;
            background: #f8f9fa;
        }
        .preview-container h5 {
            margin-top: 0;
            color: #007bff;
        }
        .preview-container img {
            max-width: 150px;
            max-height: 200px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
    </style>
</head>
<body>
<jsp:include page="../common.jsp">
    <jsp:param name="page" value="book"/>
</jsp:include>

<div class="container">
    <div class="edit-form-container">
        <h2>编辑图书</h2>

        <!-- 权限检查 -->
        <c:if test="${sessionScope.role != 'ADMIN'}">
            <div class="form-section">
                <div class="alert alert-danger">
                    <strong>权限不足！</strong> 只有管理员可以编辑图书。
                </div>
                <a href="${pageContext.request.contextPath}/book/list" class="btn btn-default">
                    <span class="glyphicon glyphicon-arrow-left"></span> 返回列表
                </a>
            </div>
        </c:if>

        <c:if test="${sessionScope.role == 'ADMIN'}">
            <form action="${pageContext.request.contextPath}/book/edit" method="post" id="editForm">
                <input type="hidden" name="id" value="${book.id}">
                <input type="hidden" name="imagePath" id="imagePath" value="${book.imagePath}">
                <div class="form-section">
                    <h4>基本信息</h4>

                    <div class="form-group">
                        <label for="title">
                            书名 <span class="required-star">*</span>
                        </label>
                        <input type="text" class="form-control" id="title" name="title"
                               value="${book.title}" required maxlength="200">
                        <div class="form-hint">请输入完整的图书名称</div>
                    </div>

                    <div class="form-group">
                        <label for="author">
                            作者 <span class="required-star">*</span>
                        </label>
                        <input type="text" class="form-control" id="author" name="author"
                               value="${book.author}" required maxlength="100">
                        <div class="form-hint">请输入作者姓名</div>
                    </div>

                    <div class="form-group">
                        <label for="isbn">
                            ISBN <span class="required-star">*</span>
                        </label>
                        <input type="text" class="form-control" id="isbn" name="isbn"
                               value="${book.isbn}" required maxlength="50">
                        <div class="form-hint">国际标准书号，用于唯一标识图书</div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="publisher">出版社</label>
                                <input type="text" class="form-control" id="publisher" name="publisher"
                                       value="${book.publisher}" maxlength="100">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="publishDate">出版日期</label>
                                <c:choose>
                                    <c:when test="${not empty book.publishDate}">
                                        <fmt:formatDate value="${book.publishDate}" pattern="yyyy-MM-dd" var="formattedDate"/>
                                        <input type="date" class="form-control" id="publishDate"
                                               name="publishDateStr" value="${formattedDate}">
                                    </c:when>
                                    <c:otherwise>
                                        <input type="date" class="form-control" id="publishDate"
                                               name="publishDateStr">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="category">分类</label>
                        <input type="text" class="form-control" id="category" name="category"
                               value="${book.category}" maxlength="50">
                        <div class="form-hint">例如：小说、计算机、历史等</div>
                    </div>

                    <div class="form-group">
                        <label for="description">描述</label>
                        <textarea class="form-control" id="description" name="description"
                                  rows="4" maxlength="1000">${book.description}</textarea>
                        <div class="form-hint">可输入图书简介、内容提要等信息</div>
                    </div>
                </div>

                <div class="form-section">
                    <h4>图书封面</h4>

                    <div class="form-group">
                        <label>当前封面</label>
                        <div class="image-preview" id="imagePreview">
                            <c:choose>
                                <c:when test="${not empty book.imagePath}">
                                    <img id="currentImage"
                                         src="${pageContext.request.contextPath}${book.imagePath}"
                                         alt="${book.title}"
                                         style="max-width: 200px; max-height: 300px; border: 1px solid #ddd;">
                                    <br><br>
                                    <a href="javascript:void(0)" onclick="deleteBookImage(${book.id})"
                                       class="btn btn-danger btn-xs">
                                        <span class="glyphicon glyphicon-trash"></span> 删除封面
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <div class="no-image-placeholder" id="noImage">
                                        <span>暂无封面</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="imageFile">上传新封面</label>
                        <input type="file" class="form-control" id="imageFile"
                               accept="image/jpeg,image/png,image/gif,image/bmp"
                               onchange="previewImage(this)">
                        <div class="form-hint">支持jpg、png、gif、bmp格式，大小不超过5MB</div>
                    </div>

                    <!-- 新图片预览 -->
                    <div class="preview-container" id="previewContainer">
                        <h5>新封面预览:</h5>
                        <img id="previewImage">
                    </div>

                    <div class="form-group">
                        <button type="button" class="btn btn-info" onclick="uploadBookImage(${book.id})">
                            <span class="glyphicon glyphicon-upload"></span> 上传封面
                        </button>
                        <small class="text-muted" style="margin-left: 10px;">
                            注：上传前请先选择文件
                        </small>
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
                                       name="totalCopies" value="${book.totalCopies}"
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
                                       name="availableCopies" value="${book.availableCopies}"
                                       min="0" max="${book.totalCopies}" required>
                                <div class="form-hint">当前可借出的数量</div>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="status">
                            状态 <span class="required-star">*</span>
                        </label>
                        <select class="form-control" id="status" name="status" required>
                            <option value="AVAILABLE" ${book.status == 'AVAILABLE' ? 'selected' : ''}>
                                可借
                            </option>
                            <option value="BORROWED" ${book.status == 'BORROWED' ? 'selected' : ''}>
                                已借出
                            </option>
                            <option value="MAINTENANCE" ${book.status == 'MAINTENANCE' ? 'selected' : ''}>
                                维护中
                            </option>
                        </select>
                        <div class="form-hint">当前图书的流通状态</div>
                    </div>
                </div>

                <div class="form-section" style="text-align: center;">
                    <button type="submit" class="btn btn-primary btn-lg">
                        <span class="glyphicon glyphicon-ok"></span> 保存修改
                    </button>
                    <a href="${pageContext.request.contextPath}/book/detail/${book.id}"
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
        $('#editForm').submit(function() {
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
    });

    // 图片预览功能
    function previewImage(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];

            // 验证文件大小
            if (file.size > 5 * 1024 * 1024) {
                alert('文件大小不能超过5MB！');
                input.value = '';
                return;
            }

            // 验证文件类型
            var allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/bmp'];
            if (!allowedTypes.includes(file.type)) {
                alert('只支持jpg、jpeg、png、gif、bmp格式的图片！');
                input.value = '';
                return;
            }

            var reader = new FileReader();

            reader.onload = function(e) {
                $('#previewContainer').show();
                $('#previewImage').attr('src', e.target.result);
            }

            reader.readAsDataURL(file);
        } else {
            $('#previewContainer').hide();
        }
    }

    // 上传图书封面图片
    function uploadBookImage(bookId) {
        var fileInput = document.getElementById('imageFile');
        var file = fileInput.files[0];

        if (!file) {
            alert('请选择要上传的图片');
            return;
        }

        var formData = new FormData();
        formData.append('imageFile', file);
        formData.append('bookId', bookId);

        // 显示上传中提示
        var uploadBtn = $('.btn-info');
        var originalText = uploadBtn.html();
        uploadBtn.html('<span class="glyphicon glyphicon-hourglass"></span> 上传中...').prop('disabled', true);

        $.ajax({
            url: '${pageContext.request.contextPath}/upload/bookImage',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',
            success: function(result) {
                uploadBtn.html(originalText).prop('disabled', false);

                if (result.success) {
                    alert(result.message);

                    // 更新封面显示
                    if (result.imageUrl) {
                        // 隐藏"暂无封面"和预览
                        $('#noImage').hide();
                        $('#previewContainer').hide();

                        // 创建新图片HTML
                        var imgHtml = '<img src="${pageContext.request.contextPath}' + result.imageUrl +
                            '" alt="图书封面" style="max-width: 200px; max-height: 300px; border: 1px solid #ddd;">' +
                            '<br><br>' +
                            '<a href="javascript:void(0)" onclick="deleteBookImage(' + bookId + ')"' +
                            ' class="btn btn-danger btn-xs">' +
                            '<span class="glyphicon glyphicon-trash"></span> 删除封面' +
                            '</a>';

                        $('#imagePreview').html(imgHtml);
                        $('#imagePath').val(result.imageUrl);
                        // 清空文件输入
                        $('#imageFile').val('');
                    }
                } else {
                    alert('上传失败: ' + result.message);
                }
            },
            error: function(xhr, status, error) {
                uploadBtn.html(originalText).prop('disabled', false);
                console.error('上传失败:', xhr, status, error);

                var errorMsg = '上传失败';
                try {
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        errorMsg += ': ' + xhr.responseJSON.message;
                    } else if (xhr.responseText) {
                        errorMsg += ': ' + xhr.responseText.substring(0, 100);
                    }
                } catch (e) {
                    errorMsg += ': ' + error;
                }
                alert(errorMsg);
            }
        });

    }

    // 删除图书封面图片
    function deleteBookImage(bookId) {
        if (!confirm('确定要删除图书封面吗？删除后不可恢复！')) {
            return;
        }

        $.ajax({
            url: '${pageContext.request.contextPath}/upload/deleteImage?bookId=' + bookId,
            type: 'GET',
            dataType: 'json',
            success: function(result) {
                if (result.success) {
                    alert(result.message);

                    // 恢复无封面状态
                    var noCoverHtml = '<div class="no-image-placeholder" id="noImage">' +
                        '<span>暂无封面</span>' +
                        '</div>';

                    $('#imagePreview').html(noCoverHtml);

                    $('#imagePath').val('');

                    // 清空预览
                    $('#previewContainer').hide();
                    $('#imageFile').val('');
                } else {
                    alert('删除失败: ' + result.message);
                }
            },
            error: function(xhr, status, error) {
                alert('删除失败: ' + error);
            }
        });
    }
</script>
</body>
</html>