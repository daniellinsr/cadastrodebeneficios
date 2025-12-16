import 'package:cadastro_beneficios/core/config/env_config.dart';

/// Endpoints da API
///
/// Centraliza todas as URLs dos endpoints da API
class ApiEndpoints {
  // Base URL (lê do .env via EnvConfig)
  static String get baseUrl => '${EnvConfig.backendApiUrl}/api/v1';

  // ===== Auth Endpoints =====
  static const String login = '/auth/login';
  static const String loginGoogle = '/auth/login/google';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';
  static const String sendVerificationCode = '/auth/verify/send';
  static const String verifyCode = '/auth/verify/check';

  // ===== Registration Endpoints =====
  static const String registration = '/registration';
  static String registrationById(String id) => '/registration/$id';
  static String registrationVerificationCode(String id) =>
      '/registration/$id/verification/code';
  static String registrationVerificationConfirm(String id) =>
      '/registration/$id/verification/confirm';
  static String registrationPrefill(String id) => '/registration/$id/prefill';
  static String registrationAddress(String id) => '/registration/$id/address';
  static String registrationHolder(String id) => '/registration/$id/holder';
  static String registrationDependents(String id) =>
      '/registration/$id/dependents';
  static String registrationPlan(String id) => '/registration/$id/plan';
  static String registrationPayment(String id) =>
      '/registration/$id/payment/intents';
  static String registrationApprove(String id) => '/registration/$id/approve';

  // ===== Customer Endpoints =====
  static String customerCard(String id) => '/customers/$id/card';
  static String customer(String id) => '/customers/$id';
  static String customerInvoices(String id) => '/customers/$id/invoices';
  static String customerPaymentHistory(String id) =>
      '/customers/$id/payments/history';

  // ===== Plans Endpoints =====
  static const String plans = '/plans';
  static String planById(String id) => '/plans/$id';

  // ===== Partners Endpoints =====
  static const String partners = '/partners';
  static String partnerById(String id) => '/partners/$id';
  static const String clinics = '/partners/clinics';

  // ===== Payment Endpoints =====
  static String paymentIntentConfirmCard(String id) =>
      '/payment/intents/$id/confirm-card';
  static String paymentIntentCreatePix(String id) =>
      '/payment/intents/$id/create-pix';
  static String paymentIntentConfirmDebit(String id) =>
      '/payment/intents/$id/confirm-debit';
  static String paymentIntentStatus(String id) => '/payment/intents/$id/status';

  // ===== Admin Endpoints =====
  static const String adminDashboard = '/admin/dashboard/metrics';
  static const String adminCustomers = '/admin/customers';
  static String adminCustomerById(String id) => '/admin/customers/$id';
  static const String adminPlans = '/admin/plans';
  static String adminPlanById(String id) => '/admin/plans/$id';
  static const String adminPartners = '/admin/partners';
  static String adminPartnerById(String id) => '/admin/partners/$id';
  static const String adminTransactions = '/admin/financial/transactions';
  static const String adminReports = '/admin/financial/reports';

  // ===== Communication Endpoints =====
  static const String whatsappSend = '/communication/whatsapp/send';
  static const String emailSend = '/communication/email/send';
  static const String notificationsSend = '/admin/notifications/send';
  static const String notificationsTemplates = '/admin/notifications/templates';

  // ===== Support Endpoints =====
  static const String supportWhatsapp = '/support/whatsapp';

  // ===== Privacy/LGPD Endpoints =====
  static const String privacyMyData = '/privacy/my-data';
  static const String privacyDeleteAccount = '/privacy/delete-account';
  static const String privacyExportData = '/privacy/export-data';
  static const String privacyConsents = '/privacy/consents';

  // ===== Address Endpoints =====
  static String addressByCep(String cep) => '/address/cep/$cep';

  // ===== Benefits Endpoints =====
  static const String benefits = '/benefits';
}
