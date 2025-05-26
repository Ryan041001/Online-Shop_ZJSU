import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class RegisterFrame extends JFrame {
    private JTextField usernameField;
    private JPasswordField passwordField;
    private JTextField emailField;
    private JTextField phoneField;
    private JTextField addressField;
    private JComboBox<String> userTypeComboBox;

    public RegisterFrame() {
        setTitle("用户注册");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(7, 2));

        panel.add(new JLabel("用户名:"));
        usernameField = new JTextField();
        panel.add(usernameField);

        panel.add(new JLabel("密码:"));
        passwordField = new JPasswordField();
        panel.add(passwordField);

        panel.add(new JLabel("邮箱:"));
        emailField = new JTextField();
        panel.add(emailField);

        panel.add(new JLabel("电话:"));
        phoneField = new JTextField();
        panel.add(phoneField);

        panel.add(new JLabel("地址:"));
        addressField = new JTextField();
        panel.add(addressField);

        panel.add(new JLabel("用户类型:"));
        userTypeComboBox = new JComboBox<>(new String[]{"普通用户", "商家"});
        panel.add(userTypeComboBox);

        JButton registerButton = new JButton("注册");
        panel.add(registerButton);

        add(panel);

        registerButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                registerUser();
            }
        });
    }

    private void registerUser() {
        String username = usernameField.getText();
        String password = new String(passwordField.getPassword());
        String email = emailField.getText();
        String phone = phoneField.getText();
        String address = addressField.getText();
        String userType = (String) userTypeComboBox.getSelectedItem();

        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call RegisterUser(?, ?, ?, ?, ?, ?, ?)}");
            cstmt.setString(1, username);
            cstmt.setString(2, password);
            cstmt.setString(3, email);
            cstmt.setString(4, phone);
            cstmt.setString(5, address);
            cstmt.setString(6, userType);
            cstmt.registerOutParameter(7, Types.INTEGER);
            cstmt.execute();

            int result = cstmt.getInt(7);
            if (result == 0) {
                JOptionPane.showMessageDialog(this, "用户注册成功！");
                dispose(); // 关闭注册界面
            } else if (result == -1) {
                JOptionPane.showMessageDialog(this, "错误：用户类型不合法！");
            } else if (result == -2) {
                JOptionPane.showMessageDialog(this, "错误：用户名已存在！");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "注册失败: " + ex.getMessage());
        }
    }
}