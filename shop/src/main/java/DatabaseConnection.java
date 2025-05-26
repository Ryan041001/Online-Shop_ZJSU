import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    // 数据库连接信息
    private static final String URL = "jdbc:sqlserver://LAPTOP-VKGO3CJE:1433;databaseName=online_shop";
    private static final String USER = "sa";
    private static final String PASSWORD = "password";

    // 获取数据库连接
    public static Connection getConnection() throws SQLException {
        try {
            // 加载 JDBC 驱动
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new SQLException("JDBC 驱动未找到！");
        }

        // 建立连接
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // 测试连接
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("数据库连接成功！");
            } else {
                System.out.println("数据库连接失败！");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("数据库连接异常: " + e.getMessage());
        }
    }
}