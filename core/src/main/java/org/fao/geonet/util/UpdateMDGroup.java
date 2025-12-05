package org.fao.geonet.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Utility to transfer metadata ownership and privileges from one group to another
 *  example usage: java -cp "*" org.fao.geonet.util.UpdateMDGroup
 *  "jdbc:postgresql://ecat-local-dev.crmtzpbmftcb.ap-southeast-2.rds.amazonaws.com:5432/ecat-local-bj-db-42x"
 *  ecat-user-bj password 2 100 2 true
 */
public class UpdateMDGroup {

    public static void main(String[] args) {
        if (args.length != 7) {
            System.err.println("usage: UpdateMDGroup db-url user-name password from-group to-group batch-size persist");
            System.exit(1);
        }

        Connection connection = null;
        Statement selectStatement = null;
        PreparedStatement updateMetadataStatement = null;
        PreparedStatement updateOperationAllowedStatement = null;
        ResultSet countResultSet = null;
        ResultSet resultSet = null;

        try {
            // 1. Establish connection
            connection = DriverManager.getConnection(args[0], args[1], args[2]);
            connection.setAutoCommit(false); // Start transaction

            // 2. Create a Statement for selecting metadata records to be updated
            selectStatement = connection.createStatement();
            String countSql = String.format("SELECT COUNT(id) FROM metadata WHERE groupowner = %s AND istemplate = 'n'",  args[3]);
            countResultSet = selectStatement.executeQuery(countSql);

            if (countResultSet.next()) {
                System.out.format("Found %d metadata records to update \n", countResultSet.getInt(1));
            } else {
                System.out.print("No metadata records to update");
                System.exit(0);
            }

            if (!Boolean.parseBoolean(args[6])) {
                System.exit(0);
            }

            String selectSql = String.format("SELECT id FROM metadata WHERE groupowner = %s AND istemplate = 'n'",  args[3]);
            resultSet = selectStatement.executeQuery(selectSql);

            // 3a. Prepare a PreparedStatement for updating metadata
            String updateSql = "UPDATE metadata SET groupowner = ? WHERE id = ?";
            updateMetadataStatement = connection.prepareStatement(updateSql);

            updateSql = "UPDATE operationallowed SET groupid=? where metadataid=? and groupid=?";
            updateOperationAllowedStatement = connection.prepareStatement(updateSql);

            int count = 0;

            // 4. Iterate over the ResultSet and perform updates
            while (resultSet.next() && count < Integer.parseInt(args[5])) {
                int id = resultSet.getInt("id");

                System.out.println("Processing metadata record with ID=" + id);

                // Set parameters for the update metadata statement
                updateMetadataStatement.setInt(1, Integer.parseInt(args[4]));
                updateMetadataStatement.setInt(2, id);

                // Set parameters for update operationalowed statement
                updateOperationAllowedStatement.setInt(1, Integer.parseInt(args[4]));
                updateOperationAllowedStatement.setInt(2, id);
                updateOperationAllowedStatement.setInt(3, Integer.parseInt(args[3]));

                // Add the update to a batch
                updateMetadataStatement.addBatch();
                updateOperationAllowedStatement.addBatch();
                count++;
            }

            // 5. Execute the batched updates
            int[] updateCounts = updateMetadataStatement.executeBatch();
            System.out.println("Updated " + updateCounts.length + " metadata rows.");

            int[] updatedOperationsAllowedCount = updateOperationAllowedStatement.executeBatch();
            System.out.println("Updated " + updatedOperationsAllowedCount.length + " operations allowed rows.");

            // 6. Commit the transaction
            connection.commit();

        } catch (SQLException e) {
            e.printStackTrace();
            if (connection != null) {
                try {
                    connection.rollback(); // Rollback on error
                    System.err.println("Transaction rolled back.");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            // 7. Close resources in reverse order of creation
            try {
                if (resultSet != null) resultSet.close();
                if (countResultSet != null) countResultSet.close();
                if (selectStatement != null) selectStatement.close();
                if (updateMetadataStatement != null) updateMetadataStatement.close();
                if (updateOperationAllowedStatement != null) updateOperationAllowedStatement.close();
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
