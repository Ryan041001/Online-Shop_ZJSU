import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class LoginFrame extends JFrame {
    private JTextField usernameField;
    private JPasswordField passwordField;
    private JComboBox<String> userTypeComboBox;

    public LoginFrame() {
        setTitle("登录");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(5, 2));

        panel.add(new JLabel("用户名:"));
        usernameField = new JTextField();
        panel.add(usernameField);

        panel.add(new JLabel("密码:"));
        passwordField = new JPasswordField();
        panel.add(passwordField);

        panel.add(new JLabel("用户类型:"));
        userTypeComboBox = new JComboBox<>(new String[]{"普通用户", "商家"});
        panel.add(userTypeComboBox);

        JButton loginButton = new JButton("登录");
        panel.add(loginButton);

        JButton registerButton = new JButton("注册");
        panel.add(registerButton);

        add(panel);

        // 登录按钮事件
        loginButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String username = usernameField.getText();
                String password = new String(passwordField.getPassword());
                String userType = (String) userTypeComboBox.getSelectedItem();

                if (authenticateUser(username, password, userType)) {
                    JOptionPane.showMessageDialog(LoginFrame.this, "登录成功！");
                    if (userType.equals("普通用户")) {
                        new UserMainFrame(username).setVisible(true); // 进入用户主界面
                    } else {
                        new SellerMainFrame(username).setVisible(true); // 进入商家主界面
                    }
                    dispose(); // 关闭登录界面
                } else {
                    JOptionPane.showMessageDialog(LoginFrame.this, "用户名或密码错误！");
                }
            }
        });

        // 注册按钮事件
        registerButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                new RegisterFrame().setVisible(true); // 打开注册界面
            }
        });
    }

    // 验证用户登录
    private boolean authenticateUser(String username, String password, String userType) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call LoginUser(?, ?)}");
            cstmt.setString(1, username);
            cstmt.setString(2, password);
            ResultSet rs = cstmt.executeQuery();

            if (rs.next()) {
                String dbUserType = rs.getString("UserType");
                return dbUserType.equals(userType); // 检查用户类型是否匹配
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "登录失败: " + ex.getMessage());
        }
        return false;
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                new LoginFrame().setVisible(true);
            }
        });
    }
}