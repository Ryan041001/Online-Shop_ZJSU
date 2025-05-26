import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class ProcessOrderFrame extends JFrame {
    private String username;
    private JComboBox<String> orderComboBox;
    private JComboBox<String> logisticsComboBox;

    public ProcessOrderFrame(String username) {
        this.username = username;
        setTitle("处理订单");
        setSize(400, 200);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(3, 2));

        panel.add(new JLabel("选择订单:"));
        orderComboBox = new JComboBox<>();
        loadOrders(); // 加载订单
        panel.add(orderComboBox);

        panel.add(new JLabel("选择快递公司:"));
        logisticsComboBox = new JComboBox<>(new String[]{"顺丰", "中通", "圆通"});
        panel.add(logisticsComboBox);

        JButton processButton = new JButton("处理订单");
        panel.add(processButton);

        add(panel);

        // 处理订单事件
        processButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedOrder = (String) orderComboBox.getSelectedItem();
                String logisticsCompany = (String) logisticsComboBox.getSelectedItem();

                // 调用存储过程 CreateDelivery
                try {
                    JOptionPane.showMessageDialog(ProcessOrderFrame.this, "订单处理成功！");
                    dispose(); // 关闭界面
                } catch (Exception ex) {
                    ex.printStackTrace();
                    JOptionPane.showMessageDialog(ProcessOrderFrame.this, "处理订单失败: " + ex.getMessage());
                }
            }
        });
    }

    // 加载订单
    private void loadOrders() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call GetSellerOrders(?)}");
            cstmt.setInt(1, getUserId(username)); // 获取商家ID
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                orderComboBox.addItem("订单ID: " + rs.getInt("OrderID"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加载订单失败: " + ex.getMessage());
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
        return -1;
    }
}