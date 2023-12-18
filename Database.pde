class Database {
  Table credit;
  Table bank;
  Table photo;
  String currentDate;
  ArrayList<Transaction> currentTransactions;  
  String[] categories = { "Food & Drink|Food",
                          "Entertainment|Fun",
                          "Bills & Utilities|Bills",
                          "Health & Wellness|Health",
                          "Payment",
                          "Shopping",
                          "Gas",
                          "Groceries",
                          "Professional Services|Services",
                          "Home",
                          "Travel",
                          "Education|School",
                          "Automotive|Car",
                          "Personal",
                          "Total|Live",
                          //"Gifts & Donations|Gifts",
                          "Deposit|Work"};
  float[] categoryTotals = new float[categories.length];
  ArrayList<String> viewedDates = new ArrayList<String>();
  color[] shadesOfRed = new color[categories.length];

  Database() {
    credit = loadTable(sketchPath("") + "data\\credit.csv", "header");
    bank = loadTable(sketchPath("") + "data\\bank.csv", "header");
    photo = loadTable(sketchPath("") + "data\\photos.csv", "header");
    println("Data Loaded:", credit, bank);
    //printColumnNames(credit);
    //printColumnNames(bank);
    //printColumnNames(photos);

    //Zero grand totals
    for (int i = 0; i < categories.length; i++)
      categoryTotals[i] = 0.0;
  
    //Create some shades of red for the graph
    for (int i = 0; i < categories.length; i++) {
      float r = map(i, 0, categories.length, 128, 255); // Increment the red component (0-255) by a step of 16
      shadesOfRed[i] = color(r, 0, 0);
    }
    
    // Deposit will be shown in green
    shadesOfRed[categories.length - 1]  = color(0, 255, 0, 128);
  }
  
  void reset() {
    for (int i = 0; i < categories.length; i++)
      categoryTotals[i] = 0.0;
    currentTransactions = null;
  }

  void view(String thumbkey) {
    if (!viewed(thumbkey)) {
      loadDate(thumbkey);
      viewedDates.add(thumbkey);
    }
  }
    
  void unview(String thumbKey) {
    viewedDates.remove(thumbKey);
  }
  
  boolean viewed(String thumbKey) {
    return viewedDates.contains(thumbKey);
  }
  
  ArrayList<Transaction> findTransactionsForDate(String dateString) {
    ArrayList<Transaction> results = new ArrayList<Transaction>();
    Table[] tables = {credit, bank};
    for (int i = 0; i < tables.length; i++) {
      Table t = tables[i];
      int[] rows = t.findRowIndices(dateString, t == credit ? 1 : 2);
      for (int index : rows) {
        TableRow row = t.getRow(index);
        String category = row.getString("Category");
        results.add(new Transaction(
          dateString,
          row.getString("Description"),
          category,
          row.getString(t == credit ? "Amount" : category.equals("Deposit") ? "Amount Credit" : "Amount Debit")));
      }
    }
    
    return results;
  }
  
  ArrayList<Transaction> loadDate(String date) {
    currentDate = date;
    //print("Loading Transactions:", currentDate);
    currentTransactions = findTransactionsForDate(currentDate);
    //println("Found:", currentTransactions.size());
    if (!viewed(date)) {
      //Update totals
      for (int i =0; i < currentTransactions.size(); i++) {
        Transaction trans = currentTransactions.get(i);
        for (int c = 0; c < categories.length; c++) {
          if (getCategory(c,false).equals(trans.category)) categoryTotals[c] += abs(trans.amount);
        }
      }
      
      categoryTotals[getCategoryIndex("Total")] += getDailyTotal();
    }

    return currentTransactions;
  }
  
  float getDailyTotal() {
    float total = 0;
    for (int i =0; i < currentTransactions.size(); i++) {
      Transaction trans = currentTransactions.get(i);
      for (int c = 0; c < categories.length - 1; c++) {
        String cat = getCategory(c,false);
        if (cat.equals(trans.category)) {
          //println(cat, abs(trans.amount));
          if (cat == "Deposit") continue; //total -= abs(trans.amount);
          else total += abs(trans.amount);
        }
      }
    }
    
    //println("DAILY TOTAL:", total);
    //("TOTAL:", getTotal());
    return total;
  }
  
  float getTotal() {
    float total = 0;
    for (int i = 0; i < categories.length - 1; i++) {
      total += categoryTotals[i];
    }
    
    return total;
  }
    
  float getDepositTotal() {
    return categoryTotals[categories.length - 1];
  }
  
  int getCategoryIndex(String category) {
    for (int c = 0; c < categories.length; c++) {
      if (getCategory(c, false).equals(category))
        return c;
    }
    
    return -1;
  }
 
  color getCategoryColor(String category) {
    for (int c = 0; c < categories.length; c++) {
      if (getCategory(c, false).equals(category))
        return shadesOfRed[c];
    }
    
    return color(0,0);
  }
  
  String getCategory(int n, boolean displayName) {
    String category = categories[n];
    String[] catParts = category.split("\\|");
    if (catParts.length == 2)
      category = catParts[displayName ? 1 : 0];
    
    return category;
  }
  
  float getTotalForCategory(String category) {
    float total = 0;

    for (int c = 0; c < categories.length; c++) {
      if (getCategory(c, false).equals(category))
        total = categoryTotals[c];
    }
    
    return total;
  }  
  
  float getDayTotalForCategory(String category, ArrayList<Transaction> transactions) {
    if (transactions == null)
      transactions = currentTransactions;
      
    float total = 0;
    if (transactions == null)
      return total;  

    for (int i = 0; i < transactions.size(); i++) {
      Transaction trans = transactions.get(i);
      if (trans.category.equals(category))
        total += abs(trans.amount);
    }
    
    return total;
  }

  void printColumnNames(Table table) {
    // Get the number of columns in the table
    int numColumns = table.getColumnCount();
  
    // Iterate through the columns and print their names
    for (int i = 0; i < numColumns; i++) {
      String columnName = table.getColumnTitle(i);
      println("Column " + i + ": " + columnName);
    }
  }
  
  PhotoInfo getPhoto(String filename) {
    //println("GETPHOTO:", filename);
    File photoFile = new File(filename);
    String filekey = photoFile.getName().substring(11, photoFile.getName().length() - 4);
    TableRow row  = photo.findRow(filekey, 1);
    return new PhotoInfo(row.getString("creationTime"),
      row.getFloat("apertureFNumber"));
  }
}
