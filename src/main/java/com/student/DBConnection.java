package com.student;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {
    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        String url = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String password = System.getenv("DB_PASSWORD");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC driver is missing from the application.", e);
        }

        if (url == null || url.isBlank()
                || user == null || user.isBlank()
                || password == null) {
            throw new SQLException(
                    "Set the DB_URL, DB_USER, and DB_PASSWORD environment variables.");
        }

        return DriverManager.getConnection(url, user, password);
    }
}
