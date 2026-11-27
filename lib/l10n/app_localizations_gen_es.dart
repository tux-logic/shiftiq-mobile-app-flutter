// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations_gen.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsGenEs extends AppLocalizationsGen {
  AppLocalizationsGenEs([String locale = 'es']) : super(locale);

  @override
  String get app_title => 'ShiftIQ Workshop';

  @override
  String get app_subtitle => 'Gestión Inteligente de Talleres Automotrices';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get close => 'Cerrar';

  @override
  String get en_vivo => 'EN VIVO';

  @override
  String get retry => 'Reintentar';

  @override
  String get add => 'Agregar';

  @override
  String get start => 'Iniciar';

  @override
  String get complete => 'Completar';

  @override
  String get cancel_upper => 'CANCELAR';

  @override
  String get unit => 'Unidad';

  @override
  String get dispatch => 'Despachar';

  @override
  String get add_part_btn => '+ Repuesto';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get email_hint => 'ej. exmaple@email.com';

  @override
  String get password => 'Contraseña';

  @override
  String get password_hint => '••••••••••••';

  @override
  String get login_btn => 'INGRESAR AL TALLER';

  @override
  String get forgot_password => '¿Olvidaste tu contraseña?';

  @override
  String get quick_access_title => 'Cuentas de Acceso Rápido (Render):';

  @override
  String get mechanic_chip => 'Mecánico: Alan Mamani';

  @override
  String get owner_chip => 'Dueño: Allan Wagner';

  @override
  String get select_branch => 'Seleccionar Sede';

  @override
  String get new_branch => 'Nueva Sede';

  @override
  String get register_new_branch => 'Registrar Nueva Sede';

  @override
  String get branch_name => 'Nombre de la Sede';

  @override
  String get branch_code => 'Código de Sede';

  @override
  String get branch_address => 'Dirección física';

  @override
  String get branch_phone => 'Teléfono';

  @override
  String get enter_this_branch => 'INGRESAR A ESTA SEDE';

  @override
  String get branch_selected => 'Sede seleccionada';

  @override
  String get branch_name_hint => 'ej. Sede Miraflores Pro';

  @override
  String get branch_code_hint => 'ej. MIRA-01';

  @override
  String get branch_address_hint => 'Av. Principal 123';

  @override
  String get branch_phone_hint => 'ej. +51987654321';

  @override
  String get branch_created_success => 'Sede creada exitosamente en Render';

  @override
  String get save_branch_backend => 'GUARDAR SEDE EN BACKEND';

  @override
  String get dashboard_tab => 'Panel';

  @override
  String get executive_dashboard => 'Panel Ejecutivo del Taller · ShiftIQ';

  @override
  String get operational_dashboard => 'Panel Operativo de Bahía · ShiftIQ';

  @override
  String get kpi_title => 'MÉTRICAS CLAVE (KPIS DE HOY)';

  @override
  String get active_work_orders => 'Órdenes de Trabajo Activas';

  @override
  String get view_all => 'Ver Todas';

  @override
  String get bays_in_service => 'Bahías en Atención';

  @override
  String get bays_active_label => '4 Bahías';

  @override
  String get bays_active_subtitle => 'Atención en Suelo de Taller';

  @override
  String get month_revenue => 'Ingresos Hoy';

  @override
  String get month_revenue_sub => '+14% vs mes anterior';

  @override
  String get work_orders_kpi => 'Órdenes Trabajo';

  @override
  String get today_appointments_kpi => 'Citas de Hoy';

  @override
  String get critical_stock_kpi => 'Stock Crítico';

  @override
  String get reorder_today => 'Reponer hoy';

  @override
  String get pending_appointments_sub => 'citas pendientes';

  @override
  String get active_bay_sub => 'en bahía activa';

  @override
  String get orders_tab => 'Órdenes';

  @override
  String get work_orders_title => 'Órdenes de Trabajo (OTs)';

  @override
  String get new_ot => 'Nueva OT';

  @override
  String get status_in_progress => 'En Progreso';

  @override
  String get status_pending => 'Pendiente';

  @override
  String get status_completed => 'Completada';

  @override
  String get emit_voucher_btn => 'EMITIR BOLETA / FACTURA SUNAT';

  @override
  String get work_order_created_success =>
      'Orden de Trabajo creada exitosamente en el taller';

  @override
  String get error_creating_order => 'Error al crear orden';

  @override
  String get new_work_order => 'Nueva Orden de Trabajo';

  @override
  String get vehicle_plate => 'Placa';

  @override
  String get brand_model_required => 'Marca y Modelo *';

  @override
  String get brand_model_hint => 'Toyota Hilux 2021';

  @override
  String get customer_name_required => 'Nombre del Cliente / Dueño *';

  @override
  String get mileage_entry_required => 'Kilometraje Ingreso *';

  @override
  String get diagnostic_summary_required =>
      'Diagnóstico Inicial / Motivo de Ingreso *';

  @override
  String get add_task => 'Agregar Tarea Mecánica';

  @override
  String get task_description => 'Descripción del Servicio';

  @override
  String get task_description_required => 'Descripción del Servicio *';

  @override
  String get task_description_hint => 'Ej. Cambio de bujías y cables';

  @override
  String get labor_price => 'Precio de Mano de Obra (S/)';

  @override
  String get labor_price_required => 'Precio de Mano de Obra (S/) *';

  @override
  String get assigned_mechanic => 'Mecánico Asignado';

  @override
  String get mechanic_name_hint => 'Ej. Luis Ramos';

  @override
  String get dispatch_part_stock => 'Despachar Repuesto de Stock';

  @override
  String get part_name_input => 'Nombre del Repuesto *';

  @override
  String get part_name_dispatch_hint => 'Ej. Pastillas Bosch Fr-02';

  @override
  String get quantity_required => 'Cantidad *';

  @override
  String get unit_price_required => 'Precio Unitario (S/) *';

  @override
  String get work_order_detail => 'Detalle de OT';

  @override
  String get work_order_not_found => 'Orden no encontrada';

  @override
  String get finalize_order_dialog_title => '¿Finalizar y Liquidar Orden?';

  @override
  String get confirm_and_settle => 'Confirmar y Liquidar';

  @override
  String get appointments_tab => 'Citas';

  @override
  String get appointments_title => 'Agenda de Citas B2B';

  @override
  String get new_appointment => 'Nueva Cita';

  @override
  String get bay => 'Bahía';

  @override
  String get open_ot => 'Abrir OT';

  @override
  String get all_appointments => 'Todas';

  @override
  String get pending_appointments => 'Pendientes';

  @override
  String get confirmed_appointments => 'Confirmadas';

  @override
  String get completed_appointments => 'Completadas';

  @override
  String get schedule_appointment => 'Agendar Cita';

  @override
  String get schedule_appointment_bay => 'Agendar Cita en Bahía';

  @override
  String get search_customer_hint => 'Buscar por nombre, placa o teléfono...';

  @override
  String get appointment_scheduled_success =>
      'Cita agendada exitosamente en bahía';

  @override
  String get select_registered_customer => 'Seleccionar Cliente Registrado';

  @override
  String get select_registered_customer_optional =>
      'Seleccionar Cliente Registrado (Opcional)';

  @override
  String get new_customer_manual => 'Cliente Nuevo / Ingresar Manualmente';

  @override
  String get full_name => 'Nombre Completo';

  @override
  String get full_name_required => 'Nombre Completo *';

  @override
  String get phone => 'Teléfono';

  @override
  String get plate_required => 'Placa *';

  @override
  String get plate_hint => 'ABC-123';

  @override
  String get model_brand => 'Modelo / Marca';

  @override
  String get model_brand_hint => 'Ej. Toyota Hilux 2021';

  @override
  String get service_type_job => 'Tipo de Servicio / Trabajo';

  @override
  String get symptoms_notes => 'Notas / Síntomas reportados';

  @override
  String get symptoms_notes_hint =>
      'Detalles del cliente o sospecha técnica...';

  @override
  String get inventory_tab => 'Inventario';

  @override
  String get sale_price => 'PRECIO VENTA';

  @override
  String get cost_price => 'COSTO COMPRA';

  @override
  String get valuation => 'VALUACIÓN';

  @override
  String get add_batch_btn => 'Lote';

  @override
  String get batch_entry => 'Ingresar Lote';

  @override
  String get new_product => 'Nuevo Repuesto';

  @override
  String get register_new_product => 'Registrar Nuevo Repuesto';

  @override
  String get search_product_hint => 'Buscar por SKU, nombre o categoría...';

  @override
  String get product_registered_success =>
      'Repuesto registrado exitosamente en el catálogo';

  @override
  String get sku_code => 'Código SKU';

  @override
  String get sku_required => 'Código SKU *';

  @override
  String get sku_hint => 'Ej. FLT-AIR-22';

  @override
  String get category => 'Categoría';

  @override
  String get category_required => 'Categoría *';

  @override
  String get part_description => 'Descripción / Nombre del Repuesto';

  @override
  String get part_name_required => 'Descripción / Nombre del Repuesto *';

  @override
  String get part_name_hint => 'Ej. Filtro de Aire Mann C25114';

  @override
  String get sale_price_required => 'Precio Venta (S/) *';

  @override
  String get cost_price_required => 'Costo Compra (S/) *';

  @override
  String get initial_stock_required => 'Stock Inicial *';

  @override
  String get min_alert_stock => 'Alerta Mínima *';

  @override
  String get compatibility_notes => 'Aplicación / Compatibilidad (Opcional)';

  @override
  String get compatibility_notes_hint =>
      'Ej. Compatible con motores 1.5L Toyota 2NR-FE...';

  @override
  String get batch_number => 'Número de Lote / Factura';

  @override
  String get batch_invoice_number => 'Número de Lote / Factura *';

  @override
  String get supplier_name => 'Proveedor / Distribuidor';

  @override
  String get supplier_distributor => 'Proveedor / Distribuidor *';

  @override
  String get quantity => 'Cantidad';

  @override
  String get quantity_with_unit => 'Cantidad';

  @override
  String get unit_cost => 'Costo Unit. (S/)';

  @override
  String get unit_cost_currency => 'Costo Unit. (S/) *';

  @override
  String get telemetry_tab => 'Telemetría';

  @override
  String get dtc_alerts => 'Alertas DTC / OBD-II';

  @override
  String get live_telemetry => 'Último Snapshot';

  @override
  String get mark_resolved => 'Marcar Resuelto';

  @override
  String get freeze_frame => 'Freeze Frame';

  @override
  String get dtc_resolved_success => 'Código DTC marcado como RESUELTO';

  @override
  String get billing_title => 'Pagos y Cotizaciones';

  @override
  String get vouchers => 'Pagos';

  @override
  String get quotes => 'Cotizaciones';

  @override
  String get client_data => 'DATOS DEL ADQUIRIENTE / CLIENTE';

  @override
  String get client_name => 'Cliente / Razón Social';

  @override
  String get document => 'Documento (DNI/RUC)';

  @override
  String get subtotal => 'Subtotal (Gravada)';

  @override
  String get igv => 'I.G.V. (18%)';

  @override
  String get total => 'Total a Pagar';

  @override
  String get pay => 'COBRAR';

  @override
  String get thermal_ticket => 'TICKET TÉRMICO';

  @override
  String get pdf_sunat => 'PDF SUNAT';

  @override
  String get emit_voucher_action => 'EMITIR COMPROBANTE';

  @override
  String get vouchers_all => 'Todos los Comprobantes';

  @override
  String get boletas_filter => 'Boletas (B001)';

  @override
  String get facturas_filter => 'Facturas (F001)';

  @override
  String get boleta_venta => 'Boleta de Venta (B001)';

  @override
  String get factura => 'Factura (F001)';

  @override
  String get liquidation_billing_title => 'Liquidación y Facturación SUNAT';

  @override
  String get payment_recorded_success => '¡Cobro registrado exitosamente!';

  @override
  String get voucher_detail => 'Detalle de Comprobante';

  @override
  String get doc_label => 'Doc.';

  @override
  String get dni_doc => 'DNI';

  @override
  String get ruc_doc => 'RUC';

  @override
  String get ce_doc => 'CE';

  @override
  String get doc_number_prefix => 'Número de';

  @override
  String get legal_name_or_full_name => 'Razón Social / Nombre Completo';

  @override
  String get fiscal_address => 'Dirección Fiscal (Lima)';

  @override
  String get profile_title => 'Mi Perfil de Taller';

  @override
  String get personal_info => 'Información Personal';

  @override
  String get edit_profile => 'EDITAR DATOS PERSONALES';

  @override
  String get logout => 'CERRAR SESIÓN DEL TALLER';

  @override
  String get language => 'Idioma de la Aplicación';

  @override
  String get first_name => 'Nombres';

  @override
  String get last_name => 'Apellidos';

  @override
  String get mobile_phone => 'Teléfono Móvil';

  @override
  String get logout_dialog_title => 'Cerrar Sesión';

  @override
  String get logout_upper => 'CERRAR SESIÓN';

  @override
  String get spanish_pe => 'Español (Perú)';

  @override
  String get english_us => 'English (US)';

  @override
  String get tooltip_customer_directory => 'Directorio de Clientes B2B';

  @override
  String get tooltip_billing => 'Pagos y Cotizaciones';

  @override
  String get tooltip_change_branch => 'Cambiar de Sede';

  @override
  String get tooltip_refresh_kpis => 'Refrescar KPIs';

  @override
  String get tooltip_refresh => 'Actualizar';

  @override
  String get tooltip_refresh_orders => 'Refrescar OTs';

  @override
  String get tooltip_refresh_sensors => 'Refrescar Sensores';

  @override
  String get tooltip_profile => 'Mi Perfil de Taller / Cerrar Sesión';

  @override
  String get tooltip_create_branch => 'Crear Nueva Sede';

  @override
  String get tooltip_share_whatsapp => 'Compartir por WhatsApp';

  @override
  String get tooltip_start_task => 'Iniciar Tarea';

  @override
  String get tooltip_complete_task => 'Marcar como Completada';

  @override
  String get all => 'Todos';

  @override
  String get search => 'Buscar';

  @override
  String get search_hint => 'Buscar...';

  @override
  String get open_ot_bay => 'Abrir OT en Bahía';

  @override
  String get auth_welcome_title => 'Bienvenido de vuelta';

  @override
  String get auth_welcome_subtitle =>
      'Inicia sesión con tu cuenta de cliente, técnico o administrador.';

  @override
  String get auth_sign_in_btn => 'Iniciar sesión';

  @override
  String get auth_no_account => '¿No tienes cuenta?';

  @override
  String get auth_create_account => 'Regístrate aquí';

  @override
  String get auth_footer_roles => 'Clientes · Técnicos · Administradores';

  @override
  String get auth_email_required => 'Ingresa tu correo electrónico';

  @override
  String get auth_email_invalid => 'Ingresa un correo electrónico válido';

  @override
  String get auth_password_required => 'Ingresa tu contraseña';

  @override
  String get auth_password_min =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get auth_password_policy =>
      'Debe incluir mayúscula, número y carácter especial';

  @override
  String get forgot_title => 'Recuperar contraseña';

  @override
  String get forgot_step1_subtitle =>
      'Ingresa tu correo registrado para recibir un token de recuperación.';

  @override
  String get forgot_send_btn => 'Enviar código de recuperación';

  @override
  String get forgot_step2_subtitle =>
      'Ingresa el token enviado a tu correo y define tu nueva contraseña.';

  @override
  String get forgot_token_label => 'Token de recuperación';

  @override
  String get forgot_token_hint => 'Pega el token recibido por correo';

  @override
  String get forgot_token_required => 'Ingresa el token de recuperación';

  @override
  String get forgot_new_password_label => 'Nueva contraseña';

  @override
  String get forgot_reset_btn => 'Restablecer contraseña';

  @override
  String get forgot_success_msg =>
      'Contraseña actualizada. Ya puedes iniciar sesión.';

  @override
  String get register_title => 'Crear cuenta de cliente';

  @override
  String get register_step1_subtitle =>
      'Verifica tu correo electrónico mediante un código OTP de 6 dígitos.';

  @override
  String get register_send_otp_btn => 'Enviar código OTP';

  @override
  String get register_step2_subtitle =>
      'Ingresa el código de 6 dígitos enviado a tu correo.';

  @override
  String get register_otp_label => 'Código OTP (6 dígitos)';

  @override
  String get register_otp_required => 'Ingresa el código de 6 dígitos';

  @override
  String get register_verify_otp_btn => 'Verificar código';

  @override
  String get register_resend_otp => 'Reenviar código';

  @override
  String get register_step3_subtitle =>
      'Correo verificado. Crea una contraseña segura para tu cuenta.';

  @override
  String get register_confirm_password_label => 'Confirmar contraseña';

  @override
  String get register_password_mismatch => 'Las contraseñas no coinciden';

  @override
  String get register_submit_btn => 'Crear cuenta';

  @override
  String get customer_portal_title => 'ShiftIQ Cliente';

  @override
  String get role_customer_badge => 'CUENTA CLIENTE';

  @override
  String get customer_welcome_title => 'Tu taller conectado';

  @override
  String get customer_welcome_subtitle =>
      'Consulta el estado de tus vehículos, citas programadas y órdenes de servicio.';

  @override
  String get customer_services_section => 'TUS MÓDULOS DE CLIENTE';

  @override
  String get customer_vehicles_title => 'Mis Vehículos';

  @override
  String get customer_vehicles_subtitle =>
      'Historial técnico y alertas de diagnóstico OBD2';

  @override
  String get customer_appointments_title => 'Mis Citas';

  @override
  String get customer_appointments_subtitle =>
      'Agenda y seguimiento de atención en sede';

  @override
  String get customer_orders_title => 'Órdenes y Cotizaciones';

  @override
  String get customer_orders_subtitle =>
      'Revisa avances, aprobaciones y comprobantes';

  @override
  String get customer_logout_confirm => '¿Deseas cerrar tu sesión actual?';

  @override
  String get org_active_branch => 'Organización y Sede Activa';

  @override
  String get assigned_branch => 'Sede Asignada';

  @override
  String get active_branch_label => 'Sede Activa';

  @override
  String get specialty_label => 'Especialidad';

  @override
  String get base_salary_label => 'Salario Base';

  @override
  String get security_section => 'Seguridad';

  @override
  String get biometric_fingerprint_title => 'Ingreso con huella digital';

  @override
  String get biometric_face_title => 'Ingreso con reconocimiento facial';

  @override
  String get biometric_both_title => 'Ingreso con huella o rostro';

  @override
  String get biometric_default_title => 'Desbloqueo biométrico';

  @override
  String get biometric_subtitle =>
      'Solicitar verificación al abrir la aplicación';

  @override
  String get biometric_enabled_toast => 'Desbloqueo biométrico activado';

  @override
  String get biometric_disabled_toast => 'Desbloqueo biométrico desactivado';

  @override
  String get biometric_error_toast => 'No se pudo verificar la biometría.';

  @override
  String get workshop_settings_title => 'Configuración del Taller';

  @override
  String get services_catalog_title => 'Catálogo de Servicios';

  @override
  String get services_catalog_subtitle =>
      'Gestionar servicios y tarifas de la sede';

  @override
  String get workshop_branches_title => 'Sedes del Taller';

  @override
  String get workshop_branches_subtitle =>
      'Cambiar o administrar sedes activas';

  @override
  String get badge_owner_admin => 'DUEÑO / ADMIN';

  @override
  String get badge_workshop_staff => 'PERSONAL TALLER';

  @override
  String get switch_branch_title => 'Cambiar de sede';

  @override
  String get view_on_map => 'Ver en mapa';

  @override
  String get no_branches_available => 'No se encontraron sedes disponibles.';

  @override
  String get network_prefix => 'Red';

  @override
  String get billing_subtitle => 'Pagos y cotizaciones del taller';

  @override
  String get today_collections => 'Cobros Hoy';

  @override
  String get pending_collections => 'Por Cobrar';

  @override
  String get payments_count_suffix => 'pagos';

  @override
  String get no_vouchers_title => 'No se encontraron comprobantes emitidos';

  @override
  String get no_vouchers_subtitle =>
      'Desliza hacia abajo para actualizar o registra un cobro';

  @override
  String get no_quotes_title => 'No hay cotizaciones registradas';

  @override
  String get pull_to_refresh_hint => 'Desliza hacia abajo para actualizar';

  @override
  String get services_catalog_subtitle_page =>
      'Servicios de mano de obra de la sede';

  @override
  String get new_service => 'Nuevo Servicio';

  @override
  String get edit_service => 'Editar Servicio';

  @override
  String get service_name_label => 'Nombre del servicio *';

  @override
  String get service_price_label => 'Precio (S/) *';

  @override
  String get save_service => 'Guardar Servicio';

  @override
  String get update_service => 'Actualizar Servicio';

  @override
  String get no_services_title => 'Sin servicios registrados';

  @override
  String get no_services_subtitle =>
      'Crea los servicios que ofrece esta sede para usarlos al agendar citas';

  @override
  String get biometric_lock_title => 'Sesión Protegida';

  @override
  String get biometric_use_another_account => 'Usar otra cuenta';

  @override
  String get biometric_verifying => 'Verificando...';

  @override
  String get biometric_unlock_fingerprint => 'Desbloquear con Huella Digital';

  @override
  String get biometric_unlock_face => 'Desbloquear con Rostro';

  @override
  String get biometric_unlock_both => 'Desbloquear con Huella / Rostro';

  @override
  String get biometric_optin_title => '¿Activar ingreso rápido?';

  @override
  String get biometric_not_now => 'Ahora no';

  @override
  String get customer_tab_summary => 'Resumen';

  @override
  String get customer_tab_vehicles => 'Vehículos';

  @override
  String get customer_tab_orders => 'Órdenes';

  @override
  String get customer_tab_payments => 'Pagos';

  @override
  String get customer_vehicles_header_sub =>
      'Tus vehículos y diagnóstico OBD-II';

  @override
  String get customer_orders_header_sub => 'Seguimiento de órdenes en taller';

  @override
  String get customer_payments_header_sub =>
      'Aprobación de presupuestos y pagos';

  @override
  String get no_active_orders_branch => 'No hay órdenes activas en esta sede.';

  @override
  String get general_inspection => 'Revisión general';

  @override
  String get stock_restock_needed => 'Stock por reponer';

  @override
  String get stock_healthy => 'Stock saludable';

  @override
  String get obd2_review_needed => 'Revisión OBD-II';

  @override
  String get telemetry_stable => 'Telemetría estable';

  @override
  String get new_work_order_short => 'Nueva OT';

  @override
  String get schedule_appointment_short => 'Agendar cita';

  @override
  String get batch_entry_short => 'Ingreso lote';

  @override
  String get revenue_title => 'Ingresos';

  @override
  String get no_revenue_movements => 'Sin movimientos registrados';

  @override
  String get operational_activity => 'Actividad operativa';

  @override
  String get work_orders_short => 'OTs';

  @override
  String get no_activity_recorded => 'Sin actividad registrada';

  @override
  String get weekly_productivity => 'Productividad Semanal';

  @override
  String get tasks_completed_7d => 'tareas completadas en 7 días';

  @override
  String get task_completed_7d => 'tarea completada en 7 días';

  @override
  String get task_singular => 'tarea';

  @override
  String get tasks_plural => 'tareas';

  @override
  String get bay_status_title => 'Estado en Bahía';

  @override
  String get no_tasks_registered_yet => 'Sin tareas registradas aún';

  @override
  String get task_assigned_singular => 'tarea asignada';

  @override
  String get tasks_in_queue_plural => 'tareas en tu cola';

  @override
  String get completed_status => 'Completado';

  @override
  String get completed_plural => 'Completadas';

  @override
  String get in_progress_status => 'En progreso';

  @override
  String get pending_plural => 'Pendientes';

  @override
  String get progress_by_order => 'Avance por Orden';

  @override
  String get ready_short => 'Listas';

  @override
  String get pending_short => 'Pend.';

  @override
  String get add_vehicle => 'Agregar vehículo';

  @override
  String get add_vehicle_title => 'Registrar Nuevo Vehículo';

  @override
  String get vehicle_plate_label => 'Placa *';

  @override
  String get vehicle_brand_label => 'Marca *';

  @override
  String get vehicle_model_label => 'Modelo *';

  @override
  String get vehicle_year_label => 'Año *';

  @override
  String get vehicle_vin_label => 'VIN (17 caracteres) *';

  @override
  String get vehicle_vin_error => 'El VIN debe tener exactamente 17 caracteres';

  @override
  String get vehicle_year_error => 'Ingrese un año válido';

  @override
  String get vehicle_save_btn => 'Guardar Vehículo';

  @override
  String get vehicle_registered_success => 'Vehículo registrado correctamente';

  @override
  String get no_vehicles_title => 'Sin vehículos registrados';

  @override
  String get no_vehicles_subtitle =>
      'Registra tu vehículo para ver aquí su telemetría OBD-II, alertas DTC e historial en taller.';

  @override
  String get customer_my_workshop_section => 'MI TALLER ASOCIADO';

  @override
  String get customer_no_workshop_title => 'Sin taller asociado';

  @override
  String get customer_no_workshop_subtitle =>
      'Cuando un taller te registre como cliente activo, verás aquí sus sedes y podrás agendar citas.';

  @override
  String get customer_upcoming_appointments_section => 'PRÓXIMAS CITAS';

  @override
  String get customer_no_upcoming_appointments =>
      'No tienes citas programadas próximamente.';

  @override
  String get customer_schedule_appointment => 'Agendar cita';

  @override
  String get customer_free_bays_today => 'bahías libres hoy';

  @override
  String get customer_select_branch => 'Sede del taller *';

  @override
  String get customer_select_vehicle => 'Vehículo *';

  @override
  String get customer_appointment_date_time => 'Fecha y hora *';

  @override
  String get customer_appointment_notes_hint => 'Motivo o notas (opcional)';

  @override
  String get customer_appointment_created_success =>
      'Cita agendada correctamente';

  @override
  String get customer_appointment_future_required =>
      'Elige una fecha y hora futura';

  @override
  String get customer_add_vehicle_first =>
      'Registra primero un vehículo en la pestaña Vehículos para agendar una cita.';

  @override
  String get vehicle_pick_photo_gallery => 'Galería';

  @override
  String get vehicle_pick_photo_camera => 'Cámara';

  @override
  String get customer_appointments_header_sub =>
      'Agenda y consulta tus próximas visitas';
}
