import javax.swing.*;
import java.awt.*;
import java.sql.*;

public class ViewOrdersFrame extends JFrame {
    private String username;
    private JList<String> orderList;
    private DefaultListModel<String> listModel;

    public ViewOrdersFrame(String username) {
        this.username = username;
        setTitle("订单列表 - " + username);
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new BorderLayout());

        // 订单列表
        listModel = new DefaultListModel<>();
        orderList = new JList<>(listModel);
        JScrollPane scrollPane = new JScrollPane(orderList);
        panel.add(scrollPane, BorderLayout.CENTER);

        add(panel);

        // 加载订单列表
        loadOrders();
    }

    // 加载订单列表
    private void loadOrders() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call GetSellerOrders(?)}");
            cstmt.setInt(1, getUserId(username)); // 获取商家ID
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                String orderInfo = "订单ID: " + rs.getInt("OrderID") + " - " +
                        "用户ID: " + rs.getInt("UserID") + " - " +
                        "总金额: " + rs.getDouble("TotalAmount") + " - " +
                        "状态: " + rs.getString("Status") + " - " +
                        "收货地址: " + rs.getString("DeliveryAddress");
                listModel.addElement(orderInfo);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加载订单列表失败: " + ex.getMessage());
        }
    }

    // 根据用户名获取用户ID
    private int getUserId(String username) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement pstmt = conn.prepareStatement("SELECT UserID FROM Users WHERE Username = ?");
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("UserID");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1; // 如果未找到用户，返回 -1
    }
}