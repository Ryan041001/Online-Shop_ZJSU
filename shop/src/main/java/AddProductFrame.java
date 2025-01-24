import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;

public class AddProductFrame extends JFrame {
    private String username;
    private JTextField productNameField;
    private JTextField descriptionField;
    private JComboBox<String> categoryComboBox;
    private JTextField priceField;
    private JTextField stockQuantityField;
    private JComboBox<String> statusComboBox;

    public AddProductFrame(String username) {
        this.username = username;
        setTitle("添加商品");
        setSize(400, 300);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(7, 2));

        panel.add(new JLabel("商品名称:"));
        productNameField = new JTextField();
        panel.add(productNameField);

        panel.add(new JLabel("商品描述:"));
        descriptionField = new JTextField();
        panel.add(descriptionField);

        panel.add(new JLabel("商品品类:"));
        categoryComboBox = new JComboBox<>();
        loadCategories(); // 加载商品品类名称
        panel.add(categoryComboBox);

        panel.add(new JLabel("价格:"));
        priceField = new JTextField();
        panel.add(priceField);

        panel.add(new JLabel("库存数量:"));
        stockQuantityField = new JTextField();
        panel.add(stockQuantityField);

        panel.add(new JLabel("状态:"));
        statusComboBox = new JComboBox<>(new String[]{"上架", "下架"});
        panel.add(statusComboBox);

        JButton addButton = new JButton("添加");
        panel.add(addButton);

        add(panel);

        // 添加商品事件
        addButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                addProduct();
            }
        });
    }

    // 加载商品品类名称
    private void loadCategories() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call GetCategories}");
            ResultSet rs = cstmt.executeQuery();

            while (rs.next()) {
                String categoryName = rs.getString("CategoryName");
                categoryComboBox.addItem(categoryName);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "加载商品品类失败: " + ex.getMessage());
        }
    }

    // 添加商品
    private void addProduct() {
        String productName = productNameField.getText();
        String description = descriptionField.getText();
        String categoryName = (String) categoryComboBox.getSelectedItem(); // 获取选中的品类名称
        double price = Double.parseDouble(priceField.getText());
        int stockQuantity = Integer.parseInt(stockQuantityField.getText());
        String status = (String) statusComboBox.getSelectedItem();

        // 根据品类名称获取品类ID
        int categoryId = getCategoryIdByName(categoryName);
        if (categoryId == -1) {
            JOptionPane.showMessageDialog(this, "错误：未找到品类ID！");
            return;
        }

        // 获取商家ID
        int sellerId = getUserId(username); // 根据用户名获取商家ID
        if (sellerId == -1) {
            JOptionPane.showMessageDialog(this, "错误：未找到商家ID！");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call InsertProduct(?, ?, ?, ?, ?, ?, ?)}");
            cstmt.setString(1, productName);          // @ProductName (NVARCHAR)
            cstmt.setString(2, description);          // @Description (NVARCHAR)
            cstmt.setInt(3, categoryId);              // @CategoryID (INT)
            cstmt.setDouble(4, price);                // @Price (DECIMAL)
            cstmt.setInt(5, stockQuantity);           // @StockQuantity (INT)
            cstmt.setString(6, status);               // @Status (NVARCHAR)
            cstmt.setInt(7, sellerId);                // @SellerID (INT)
            cstmt.execute();

            JOptionPane.showMessageDialog(this, "商品添加成功！");
            dispose(); // 关闭界面
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "添加商品失败: " + ex.getMessage());
        }
    }

    // 根据品类名称获取品类ID
    private int getCategoryIdByName(String categoryName) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            CallableStatement cstmt = conn.prepareCall("{call GetCategoryIdByName(?)}");
            cstmt.setString(1, categoryName);
            ResultSet rs = cstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("CategoryID");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1; // 如果未找到品类，返回 -1
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