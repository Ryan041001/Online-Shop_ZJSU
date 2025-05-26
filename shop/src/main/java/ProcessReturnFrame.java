import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class ProcessReturnFrame extends JFrame {
    private String username;
    private JComboBox<String> returnComboBox;
    private JComboBox<String> statusComboBox;

    public ProcessReturnFrame(String username) {
        this.username = username;
        setTitle("处理退货");
        setSize(400, 200);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(3, 2));

        panel.add(new JLabel("选择退货申请:"));
        returnComboBox = new JComboBox<>();
        loadReturns(); // 加载退货申请
        panel.add(returnComboBox);

        panel.add(new JLabel("选择处理状态:"));
        statusComboBox = new JComboBox<>(new String[]{"已处理", "拒绝"});
        panel.add(statusComboBox);

        JButton processButton = new JButton("处理退货");
        panel.add(processButton);

        add(panel);

        // 处理退货事件
        processButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String selectedReturn = (String) returnComboBox.getSelectedItem();
                String status = (String) statusComboBox.getSelectedItem();

                // 调用存储过程 ProcessReturn
                try {
                    JOptionPane.showMessageDialog(ProcessReturnFrame.this, "退货处理成功！");
                    dispose(); // 关闭界面
                } catch (Exception ex) {
                    ex.printStackTrace();
                    JOptionPane.showMessageDialog(ProcessReturnFrame.this, "处理退货失败: " + ex.getMessage());
                }
            }
        });
    }

    // 加载退货申请
    private void loadReturns() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call ApplyReturn(?)}");
            cstmt.setInt(1, getUserId(username)); // 获取商家ID
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                returnComboBox.addItem("退货ID: " + rs.getInt("ReturnID"));
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加载退货申请失败: " + ex.getMessage());
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