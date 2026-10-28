package com.student;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StudentServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchTerm = request.getParameter("q");
        searchTerm = searchTerm == null ? "" : searchTerm.trim();
        showPage(request, response, searchTerm, takeFlashMessage(request), null);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addStudent(request, response);
        } else if ("delete".equals(action)) {
            deleteStudent(request, response);
        } else {
            showPage(request, response, "", null, "Unknown request. Please try again.");
        }
    }

    private void addStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email"));
        String course = trim(request.getParameter("course"));

        if (isBlank(name) || isBlank(email) || isBlank(course)) {
            showPage(request, response, "", null,
                    "Name, email, and course are required.");
            return;
        }

        if (name.length() > 100 || email.length() > 120 || course.length() > 80
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            showPage(request, response, "", null,
                    "Check the field lengths and enter a valid email address.");
            return;
        }

        String sql = "INSERT INTO students (name, email, course) VALUES (?, ?, ?)";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name);
            statement.setString(2, email);
            statement.setString(3, course);
            statement.executeUpdate();
            redirectWithMessage(request, response, "Student added successfully.");
        } catch (SQLException e) {
            getServletContext().log("Could not add student.", e);
            showPage(request, response, "", null,
                    "Could not save the student. Check the database setup and try again.");
        }
    }

    private void deleteStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idValue = trim(request.getParameter("id"));
        int id;
        try {
            id = Integer.parseInt(idValue);
            if (id <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            showPage(request, response, "", null, "Invalid student ID.");
            return;
        }

        String sql = "DELETE FROM students WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            if (statement.executeUpdate() == 0) {
                showPage(request, response, "", null, "That student record was not found.");
            } else {
                redirectWithMessage(request, response, "Student record deleted.");
            }
        } catch (SQLException e) {
            getServletContext().log("Could not delete student.", e);
            showPage(request, response, "", null,
                    "Could not delete the student. Check the database setup and try again.");
        }
    }

    private void showPage(HttpServletRequest request, HttpServletResponse response,
                          String searchTerm, String message, String error)
            throws ServletException, IOException {
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("message", message);
        if (error != null) {
            request.setAttribute("error", error);
        }

        try {
            request.setAttribute("students", findStudents(searchTerm));
        } catch (SQLException e) {
            getServletContext().log("Could not load student records.", e);
            request.setAttribute("students", List.of());
            request.setAttribute("error",
                    "Could not connect to the database. Check MySQL and DB_* settings.");
        }
        request.getRequestDispatcher("/students.jsp").forward(request, response);
    }

    private List<Student> findStudents(String searchTerm) throws SQLException {
        List<Student> students = new ArrayList<>();
        boolean searching = !searchTerm.isBlank();
        String sql = searching
                ? "SELECT id, name, email, course FROM students "
                    + "WHERE name LIKE ? OR email LIKE ? OR course LIKE ? ORDER BY id DESC"
                : "SELECT id, name, email, course FROM students ORDER BY id DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            if (searching) {
                String pattern = "%" + searchTerm + "%";
                statement.setString(1, pattern);
                statement.setString(2, pattern);
                statement.setString(3, pattern);
            }

            try (ResultSet results = statement.executeQuery()) {
                while (results.next()) {
                    students.add(new Student(
                            results.getInt("id"),
                            results.getString("name"),
                            results.getString("email"),
                            results.getString("course")));
                }
            }
        }
        return students;
    }

    private void redirectWithMessage(HttpServletRequest request,
                                     HttpServletResponse response, String message)
            throws IOException {
        request.getSession().setAttribute("flashMessage", message);
        response.sendRedirect(request.getContextPath() + "/students");
    }

    private String takeFlashMessage(HttpServletRequest request) {
        var session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object message = session.getAttribute("flashMessage");
        session.removeAttribute("flashMessage");
        return message instanceof String ? (String) message : null;
    }

    private static String trim(String value) {
        return value == null ? null : value.trim();
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
