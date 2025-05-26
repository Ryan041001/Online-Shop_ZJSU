import javax.swing.*;
import java.awt.*;
import java.sql.*;

public class ViewCategoriesFrame extends JFrame {
    private JList<String> categoryList;
    private DefaultListModel<String> listModel;

    public ViewCategoriesFrame() {
        setTitle("查看商品品类");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new BorderLayout());

        // 品类列表
        listModel = new DefaultListModel<>();
        categoryList = new JList<>(listModel);
        JScrollPane scrollPane = new JScrollPane(categoryList);
        panel.add(scrollPane, BorderLayout.CENTER);

        add(panel);

        // 加载品类列表
        loadCategories();
    }

    // 加载品类列表
    private void loadCategories() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call GetCategories}");
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                String categoryInfo = "品类ID: " + rs.getInt("CategoryID") + " - " +
                        rs.getString("CategoryName");
                listModel.addElement(categoryInfo);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加载品类列表失败: " + ex.getMessage());
        }
    }
}