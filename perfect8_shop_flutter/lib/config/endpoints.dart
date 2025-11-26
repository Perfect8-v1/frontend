class Endpoints {
  // Product
  static const products = "/api/products";
  static String productById(int id) => "/api/products/$id";
  static String productsByCategory(int categoryId) =>
      "/api/products/category/$categoryId";
  static const productsActive = "/api/products/active";
  static const productsFeatured = "/api/products/featured";
  static const productsSearch = "/api/products/search";

  // Category
  static const categories = "/api/categories";
  static const categoriesActive = "/api/categories/active";
  static const categoryTree = "/api/categories/tree";

  // Auth (Admin or customer login in your backend; here we mock)
  static const authLogin = "/api/auth/login";
  static const authMe = "/api/auth/me";
}
