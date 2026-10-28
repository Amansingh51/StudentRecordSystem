<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>StudentHub | Student Records</title>
    <link rel="stylesheet" href="<c:url value='/style.css' />">
</head>
<body>
<header class="site-header">
    <div class="container header-content">
        <a class="brand" href="<c:url value='/students' />">StudentHub</a>
        <span class="header-note">Student Record Management</span>
    </div>
</header>

<main class="container main-content">
    <section class="intro">
        <p class="eyebrow">STUDENT MANAGEMENT</p>
        <h1>Keep your records organized.</h1>
        <p>Add students, find records, and manage course information in one place.</p>
    </section>

    <c:if test="${not empty message}">
        <div class="notice success" role="status"><c:out value="${message}" /></div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="notice error" role="alert"><c:out value="${error}" /></div>
    </c:if>

    <section class="card">
        <div class="section-heading">
            <div>
                <p class="eyebrow">NEW RECORD</p>
                <h2>Register a student</h2>
            </div>
        </div>
        <form action="<c:url value='/students' />" method="post" class="student-form">
            <input type="hidden" name="action" value="add">
            <label>
                Full name
                <input type="text" name="name" maxlength="100" required
                       value="<c:out value='${param.name}' />" placeholder="e.g. Alex Morgan">
            </label>
            <label>
                Email address
                <input type="email" name="email" maxlength="120" required
                       value="<c:out value='${param.email}' />" placeholder="alex@example.com">
            </label>
            <label>
                Course
                <input type="text" name="course" maxlength="80" required
                       value="<c:out value='${param.course}' />" placeholder="e.g. Computer Science">
            </label>
            <button type="submit" class="button button-primary">Add student</button>
        </form>
    </section>

    <section class="card records-card">
        <div class="section-heading records-heading">
            <div>
                <p class="eyebrow">DIRECTORY</p>
                <h2>Student records</h2>
            </div>
            <form action="<c:url value='/students' />" method="get" class="search-form">
                <label class="visually-hidden" for="search">Search students</label>
                <input id="search" type="search" name="q"
                       value="<c:out value='${searchTerm}' />"
                       placeholder="Search name, email, or course">
                <button type="submit" class="button button-secondary">Search</button>
                <c:if test="${not empty searchTerm}">
                    <a class="clear-link" href="<c:url value='/students' />">Clear</a>
                </c:if>
            </form>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th scope="col">Name</th>
                    <th scope="col">Email</th>
                    <th scope="col">Course</th>
                    <th scope="col">Action</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="student" items="${students}">
                    <tr>
                        <td data-label="Name"><c:out value="${student.name}" /></td>
                        <td data-label="Email"><c:out value="${student.email}" /></td>
                        <td data-label="Course"><c:out value="${student.course}" /></td>
                        <td data-label="Action">
                            <form action="<c:url value='/students' />" method="post"
                                  onsubmit="return confirm('Delete this student record?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id"
                                       value="<c:out value='${student.id}' />">
                                <button type="submit" class="button button-delete">Delete</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty students}">
                    <tr>
                        <td colspan="4" class="empty-state">
                            No student records found. Add a student or change your search.
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </section>
</main>

<footer class="site-footer">
    <div class="container">StudentHub · Student Record Management System</div>
</footer>
</body>
</html>
