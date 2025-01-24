import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.CallableStatement;
import java.sql.Connection;

public class CreateOrderFrame extends JFrame {
    private JTextField userIdField;
    private JTextField deliveryAddressField;

    public CreateOrderFrame() {
        setTitle("创建订单");
        setSize(400, 200);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(3, 2));

        panel.add(new JLabel("用户ID:"));
        userIdField = new JTextField();
        panel.add(userIdField);

        panel.add(new JLabel("配送地址:"));
        deliveryAddressField = new JTextField();
        panel.add(deliveryAddressField);

        JButton createOrderButton = new JButton("创建订单");
        panel.add(createOrderButton);

        add(panel);

        createOrderButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                createOrder();
            }
        });
    }

    private void createOrder() {
        int userId = Integer.parseInt(userIdField.getText());
        String deliveryAddress = deliveryAddressField.getText();

        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call CreateOrderWithPromotion(?, ?)}");
            cstmt.setInt(1, userId);
            cstmt.setString(2, deliveryAddress);
            cstmt.execute();

            JOptionPane.showMessageDialog(this, "订单创建成功，优惠已应用！");
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "创建订单失败: " + ex.getMessage());
        }
    }
}