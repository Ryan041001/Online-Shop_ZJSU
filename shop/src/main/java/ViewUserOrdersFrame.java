import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class ViewUserOrdersFrame extends JFrame {
    private String username;
    private JList<String> orderList;
    private DefaultListModel<String> listModel;

    public ViewUserOrdersFrame(String username) {
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

        // 支付按钮
        JButton payButton = new JButton("支付");
        panel.add(payButton, BorderLayout.SOUTH);

        add(panel);

        // 加载订单列表
        loadOrders();

        // 支付事件
        payButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                payOrder();
            }
        });
    }

    // 加载订单列表
    private void loadOrders() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call GetUserOrders(?)}");
            cstmt.setInt(1, getUserId(username)); // 获取用户ID
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                String orderInfo = "订单ID: " + rs.getInt("OrderID") + " - " +
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

    // 支付订单
    private void payOrder() {
        String selectedOrder = orderList.getSelectedValue();
        if (selectedOrder == null) {
            JOptionPane.showMessageDialog(this, "请选择一个订单！");
            return;
        }

        // 解析订单ID
        int orderId = Integer.parseInt(selectedOrder.split(" - ")[0].replace("订单ID: ", ""));

        try (Connection conn = DatabaseConnection.getConnection()) {
            // 调用存储过程更新订单状态为“已支付”
            CallableStatement updateStmt = conn.prepareCall("{call UpdateOrderStatus(?)}");
            updateStmt.setInt(1, orderId); // @OrderID (INT)
            updateStmt.execute();

            JOptionPane.showMessageDialog(this, "订单支付成功！");
            loadOrders(); // 刷新订单列表
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "支付失败: " + ex.getMessage());
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