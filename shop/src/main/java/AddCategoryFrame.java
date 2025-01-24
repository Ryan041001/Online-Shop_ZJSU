import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class AddCategoryFrame extends JFrame {
    private JTextField categoryNameField;

    public AddCategoryFrame() {
        setTitle("添加商品品类");
        setSize(400, 200);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(2, 2));

        panel.add(new JLabel("品类名称:"));
        categoryNameField = new JTextField();
        panel.add(categoryNameField);

        JButton addButton = new JButton("添加");
        panel.add(addButton);

        add(panel);

        // 添加品类事件
        addButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String categoryName = categoryNameField.getText();
                if (!categoryName.isEmpty()) {
                    addCategory(categoryName);
                } else {
                    JOptionPane.showMessageDialog(AddCategoryFrame.this, "请输入品类名称！");
                }
            }
        });
    }

    // 添加品类
    private void addCategory(String categoryName) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call AddCategory(?)}");
            cstmt.setString(1, categoryName);
            cstmt.execute();

            JOptionPane.showMessageDialog(this, "品类添加成功！");
            dispose(); // 关闭界面
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "添加品类失败: " + ex.getMessage());
        }
    }
}