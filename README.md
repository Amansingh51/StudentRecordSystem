# Student Record Management System

A beginner-friendly Java web application to add, view, search, and delete student records.

## Technologies

- Java 17
- JSP and Jakarta Servlet 6.0 (Tomcat 10.1)
- JDBC and MySQL Connector/J
- MySQL 8
- Maven WAR packaging
- HTML and CSS

## Features

- Add a student with a name, email, and course
- View student records in a responsive table
- Search by name, email, or course
- Delete a record with a confirmation prompt
- Validate required input and student IDs
- Use prepared statements for every SQL query
- Keep database credentials in environment variables

## Prerequisites

Install JDK 17, Maven, MySQL Server 8, Apache Tomcat 10.1, and Visual Studio Code. In VS Code, install the **Extension Pack for Java** and **Maven for Java** extensions. The Community Server Connectors extension is optional.

Check Java and Maven from a new VS Code terminal:

```powershell
java -version
mvn -version
```

## Database setup

1. Start MySQL Server and open MySQL Workbench.
2. Open `database.sql` in Workbench and execute it.
3. This creates `student_records`, the `students` table, and three example rows.
4. Configure these Windows user environment variables: `DB_URL`, `DB_USER`, and `DB_PASSWORD`.

Example `DB_URL`:

```text
jdbc:mysql://localhost:3306/student_records?serverTimezone=UTC
```

Use the username and password of a MySQL account that can access this database. Set variables from Windows **Edit environment variables for your account**. Restart VS Code and Tomcat after changing them so those processes see the updated values. Never put the actual password in source code or commit it.

## Build and deploy

From the project directory:

```powershell
mvn clean package
```

The generated WAR is `target\StudentRecordSystem.war`. Copy it to the `webapps` folder in your Tomcat 10.1 installation, adjusting the path as needed:

```powershell
Copy-Item .\target\StudentRecordSystem.war C:\apache-tomcat-10.1\webapps\
```

Start Tomcat:

```powershell
& C:\apache-tomcat-10.1\bin\startup.bat
```

Open [http://localhost:8080/StudentRecordSystem/](http://localhost:8080/StudentRecordSystem/). Stop Tomcat with `C:\apache-tomcat-10.1\bin\shutdown.bat`.

### Start with the workspace's portable tools

If you installed the project tools into `%LOCALAPPDATA%\StudentRecordSystemTools`, run this from PowerShell in the project folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\run-local.ps1
```

The script asks for your MySQL username and hidden password, rebuilds the WAR, and restarts Tomcat so it inherits the database settings. It does not save the password to a project file. Run `database.sql` in MySQL Workbench before starting the script.

## Troubleshooting

- If `java` is not recognized, install JDK 17 and configure `JAVA_HOME` and `PATH`.
- If `mvn` is not recognized, install Maven and add its `bin` folder to `PATH`.
- If database access fails, confirm MySQL is running and verify the three `DB_*` values. Check the Tomcat logs for the detailed error; the application does not display credentials.
- If Tomcat fails to start, check `JAVA_HOME` and whether port 8080 is already in use.
- Ensure the WAR is named `StudentRecordSystem.war`. Tomcat uses this filename for the application URL path.

## Push to GitHub

Create an empty GitHub repository, then run these commands from the project directory. Replace the URL with your own:

```powershell
git init
git add .
git commit -m "Add Student Record Management System"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/StudentRecordSystem.git
git push -u origin main
```
