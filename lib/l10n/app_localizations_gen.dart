import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_gen_en.dart';
import 'app_localizations_gen_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizationsGen
/// returned by `AppLocalizationsGen.of(context)`.
///
/// Applications need to include `AppLocalizationsGen.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations_gen.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizationsGen.localizationsDelegates,
///   supportedLocales: AppLocalizationsGen.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizationsGen.supportedLocales
/// property.
abstract class AppLocalizationsGen {
  AppLocalizationsGen(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizationsGen? of(BuildContext context) {
    return Localizations.of<AppLocalizationsGen>(context, AppLocalizationsGen);
  }

  static const LocalizationsDelegate<AppLocalizationsGen> delegate =
      _AppLocalizationsGenDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @app_title.
  ///
  /// In es, this message translates to:
  /// **'ShiftIQ Workshop'**
  String get app_title;

  /// No description provided for @app_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestión Inteligente de Talleres Automotrices'**
  String get app_subtitle;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @refresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get refresh;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @en_vivo.
  ///
  /// In es, this message translates to:
  /// **'EN VIVO'**
  String get en_vivo;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get add;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Iniciar'**
  String get start;

  /// No description provided for @complete.
  ///
  /// In es, this message translates to:
  /// **'Completar'**
  String get complete;

  /// No description provided for @cancel_upper.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR'**
  String get cancel_upper;

  /// No description provided for @unit.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get unit;

  /// No description provided for @dispatch.
  ///
  /// In es, this message translates to:
  /// **'Despachar'**
  String get dispatch;

  /// No description provided for @add_part_btn.
  ///
  /// In es, this message translates to:
  /// **'+ Repuesto'**
  String get add_part_btn;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get email;

  /// No description provided for @email_hint.
  ///
  /// In es, this message translates to:
  /// **'ej. exmaple@email.com'**
  String get email_hint;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @password_hint.
  ///
  /// In es, this message translates to:
  /// **'••••••••••••'**
  String get password_hint;

  /// No description provided for @login_btn.
  ///
  /// In es, this message translates to:
  /// **'INGRESAR AL TALLER'**
  String get login_btn;

  /// No description provided for @forgot_password.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgot_password;

  /// No description provided for @quick_access_title.
  ///
  /// In es, this message translates to:
  /// **'Cuentas de Acceso Rápido (Render):'**
  String get quick_access_title;

  /// No description provided for @mechanic_chip.
  ///
  /// In es, this message translates to:
  /// **'Mecánico: Alan Mamani'**
  String get mechanic_chip;

  /// No description provided for @owner_chip.
  ///
  /// In es, this message translates to:
  /// **'Dueño: Allan Wagner'**
  String get owner_chip;

  /// No description provided for @select_branch.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Sede'**
  String get select_branch;

  /// No description provided for @new_branch.
  ///
  /// In es, this message translates to:
  /// **'Nueva Sede'**
  String get new_branch;

  /// No description provided for @register_new_branch.
  ///
  /// In es, this message translates to:
  /// **'Registrar Nueva Sede'**
  String get register_new_branch;

  /// No description provided for @branch_name.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la Sede'**
  String get branch_name;

  /// No description provided for @branch_code.
  ///
  /// In es, this message translates to:
  /// **'Código de Sede'**
  String get branch_code;

  /// No description provided for @branch_address.
  ///
  /// In es, this message translates to:
  /// **'Dirección física'**
  String get branch_address;

  /// No description provided for @branch_phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get branch_phone;

  /// No description provided for @enter_this_branch.
  ///
  /// In es, this message translates to:
  /// **'INGRESAR A ESTA SEDE'**
  String get enter_this_branch;

  /// No description provided for @branch_selected.
  ///
  /// In es, this message translates to:
  /// **'Sede seleccionada'**
  String get branch_selected;

  /// No description provided for @branch_name_hint.
  ///
  /// In es, this message translates to:
  /// **'ej. Sede Miraflores Pro'**
  String get branch_name_hint;

  /// No description provided for @branch_code_hint.
  ///
  /// In es, this message translates to:
  /// **'ej. MIRA-01'**
  String get branch_code_hint;

  /// No description provided for @branch_address_hint.
  ///
  /// In es, this message translates to:
  /// **'Av. Principal 123'**
  String get branch_address_hint;

  /// No description provided for @branch_phone_hint.
  ///
  /// In es, this message translates to:
  /// **'ej. +51987654321'**
  String get branch_phone_hint;

  /// No description provided for @branch_created_success.
  ///
  /// In es, this message translates to:
  /// **'Sede creada exitosamente en Render'**
  String get branch_created_success;

  /// No description provided for @save_branch_backend.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR SEDE EN BACKEND'**
  String get save_branch_backend;

  /// No description provided for @dashboard_tab.
  ///
  /// In es, this message translates to:
  /// **'Panel'**
  String get dashboard_tab;

  /// No description provided for @executive_dashboard.
  ///
  /// In es, this message translates to:
  /// **'Panel Ejecutivo del Taller · ShiftIQ'**
  String get executive_dashboard;

  /// No description provided for @operational_dashboard.
  ///
  /// In es, this message translates to:
  /// **'Panel Operativo de Bahía · ShiftIQ'**
  String get operational_dashboard;

  /// No description provided for @kpi_title.
  ///
  /// In es, this message translates to:
  /// **'MÉTRICAS CLAVE (KPIS DE HOY)'**
  String get kpi_title;

  /// No description provided for @active_work_orders.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de Trabajo Activas'**
  String get active_work_orders;

  /// No description provided for @view_all.
  ///
  /// In es, this message translates to:
  /// **'Ver Todas'**
  String get view_all;

  /// No description provided for @bays_in_service.
  ///
  /// In es, this message translates to:
  /// **'Bahías en Atención'**
  String get bays_in_service;

  /// No description provided for @bays_active_label.
  ///
  /// In es, this message translates to:
  /// **'4 Bahías'**
  String get bays_active_label;

  /// No description provided for @bays_active_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Atención en Suelo de Taller'**
  String get bays_active_subtitle;

  /// No description provided for @month_revenue.
  ///
  /// In es, this message translates to:
  /// **'Ingresos Hoy'**
  String get month_revenue;

  /// No description provided for @month_revenue_sub.
  ///
  /// In es, this message translates to:
  /// **'+14% vs mes anterior'**
  String get month_revenue_sub;

  /// No description provided for @work_orders_kpi.
  ///
  /// In es, this message translates to:
  /// **'Órdenes Trabajo'**
  String get work_orders_kpi;

  /// No description provided for @today_appointments_kpi.
  ///
  /// In es, this message translates to:
  /// **'Citas de Hoy'**
  String get today_appointments_kpi;

  /// No description provided for @critical_stock_kpi.
  ///
  /// In es, this message translates to:
  /// **'Stock Crítico'**
  String get critical_stock_kpi;

  /// No description provided for @reorder_today.
  ///
  /// In es, this message translates to:
  /// **'Reponer hoy'**
  String get reorder_today;

  /// No description provided for @pending_appointments_sub.
  ///
  /// In es, this message translates to:
  /// **'citas pendientes'**
  String get pending_appointments_sub;

  /// No description provided for @active_bay_sub.
  ///
  /// In es, this message translates to:
  /// **'en bahía activa'**
  String get active_bay_sub;

  /// No description provided for @orders_tab.
  ///
  /// In es, this message translates to:
  /// **'Órdenes'**
  String get orders_tab;

  /// No description provided for @work_orders_title.
  ///
  /// In es, this message translates to:
  /// **'Órdenes de Trabajo (OTs)'**
  String get work_orders_title;

  /// No description provided for @new_ot.
  ///
  /// In es, this message translates to:
  /// **'Nueva OT'**
  String get new_ot;

  /// No description provided for @status_in_progress.
  ///
  /// In es, this message translates to:
  /// **'En Progreso'**
  String get status_in_progress;

  /// No description provided for @status_pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get status_pending;

  /// No description provided for @status_completed.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get status_completed;

  /// No description provided for @emit_voucher_btn.
  ///
  /// In es, this message translates to:
  /// **'EMITIR BOLETA / FACTURA SUNAT'**
  String get emit_voucher_btn;

  /// No description provided for @work_order_created_success.
  ///
  /// In es, this message translates to:
  /// **'Orden de Trabajo creada exitosamente en el taller'**
  String get work_order_created_success;

  /// No description provided for @error_creating_order.
  ///
  /// In es, this message translates to:
  /// **'Error al crear orden'**
  String get error_creating_order;

  /// No description provided for @new_work_order.
  ///
  /// In es, this message translates to:
  /// **'Nueva Orden de Trabajo'**
  String get new_work_order;

  /// No description provided for @vehicle_plate.
  ///
  /// In es, this message translates to:
  /// **'Placa'**
  String get vehicle_plate;

  /// No description provided for @brand_model_required.
  ///
  /// In es, this message translates to:
  /// **'Marca y Modelo *'**
  String get brand_model_required;

  /// No description provided for @brand_model_hint.
  ///
  /// In es, this message translates to:
  /// **'Toyota Hilux 2021'**
  String get brand_model_hint;

  /// No description provided for @customer_name_required.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Cliente / Dueño *'**
  String get customer_name_required;

  /// No description provided for @mileage_entry_required.
  ///
  /// In es, this message translates to:
  /// **'Kilometraje Ingreso *'**
  String get mileage_entry_required;

  /// No description provided for @diagnostic_summary_required.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico Inicial / Motivo de Ingreso *'**
  String get diagnostic_summary_required;

  /// No description provided for @add_task.
  ///
  /// In es, this message translates to:
  /// **'Agregar Tarea Mecánica'**
  String get add_task;

  /// No description provided for @task_description.
  ///
  /// In es, this message translates to:
  /// **'Descripción del Servicio'**
  String get task_description;

  /// No description provided for @task_description_required.
  ///
  /// In es, this message translates to:
  /// **'Descripción del Servicio *'**
  String get task_description_required;

  /// No description provided for @task_description_hint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Cambio de bujías y cables'**
  String get task_description_hint;

  /// No description provided for @labor_price.
  ///
  /// In es, this message translates to:
  /// **'Precio de Mano de Obra (S/)'**
  String get labor_price;

  /// No description provided for @labor_price_required.
  ///
  /// In es, this message translates to:
  /// **'Precio de Mano de Obra (S/) *'**
  String get labor_price_required;

  /// No description provided for @assigned_mechanic.
  ///
  /// In es, this message translates to:
  /// **'Mecánico Asignado'**
  String get assigned_mechanic;

  /// No description provided for @mechanic_name_hint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Luis Ramos'**
  String get mechanic_name_hint;

  /// No description provided for @dispatch_part_stock.
  ///
  /// In es, this message translates to:
  /// **'Despachar Repuesto de Stock'**
  String get dispatch_part_stock;

  /// No description provided for @part_name_input.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Repuesto *'**
  String get part_name_input;

  /// No description provided for @part_name_dispatch_hint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Pastillas Bosch Fr-02'**
  String get part_name_dispatch_hint;

  /// No description provided for @quantity_required.
  ///
  /// In es, this message translates to:
  /// **'Cantidad *'**
  String get quantity_required;

  /// No description provided for @unit_price_required.
  ///
  /// In es, this message translates to:
  /// **'Precio Unitario (S/) *'**
  String get unit_price_required;

  /// No description provided for @work_order_detail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de OT'**
  String get work_order_detail;

  /// No description provided for @work_order_not_found.
  ///
  /// In es, this message translates to:
  /// **'Orden no encontrada'**
  String get work_order_not_found;

  /// No description provided for @finalize_order_dialog_title.
  ///
  /// In es, this message translates to:
  /// **'¿Finalizar y Liquidar Orden?'**
  String get finalize_order_dialog_title;

  /// No description provided for @confirm_and_settle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar y Liquidar'**
  String get confirm_and_settle;

  /// No description provided for @appointments_tab.
  ///
  /// In es, this message translates to:
  /// **'Citas'**
  String get appointments_tab;

  /// No description provided for @appointments_title.
  ///
  /// In es, this message translates to:
  /// **'Agenda de Citas B2B'**
  String get appointments_title;

  /// No description provided for @new_appointment.
  ///
  /// In es, this message translates to:
  /// **'Nueva Cita'**
  String get new_appointment;

  /// No description provided for @bay.
  ///
  /// In es, this message translates to:
  /// **'Bahía'**
  String get bay;

  /// No description provided for @open_ot.
  ///
  /// In es, this message translates to:
  /// **'Abrir OT'**
  String get open_ot;

  /// No description provided for @all_appointments.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all_appointments;

  /// No description provided for @pending_appointments.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get pending_appointments;

  /// No description provided for @confirmed_appointments.
  ///
  /// In es, this message translates to:
  /// **'Confirmadas'**
  String get confirmed_appointments;

  /// No description provided for @completed_appointments.
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get completed_appointments;

  /// No description provided for @schedule_appointment.
  ///
  /// In es, this message translates to:
  /// **'Agendar Cita'**
  String get schedule_appointment;

  /// No description provided for @schedule_appointment_bay.
  ///
  /// In es, this message translates to:
  /// **'Agendar Cita en Bahía'**
  String get schedule_appointment_bay;

  /// No description provided for @search_customer_hint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre, placa o teléfono...'**
  String get search_customer_hint;

  /// No description provided for @appointment_scheduled_success.
  ///
  /// In es, this message translates to:
  /// **'Cita agendada exitosamente en bahía'**
  String get appointment_scheduled_success;

  /// No description provided for @select_registered_customer.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Cliente Registrado'**
  String get select_registered_customer;

  /// No description provided for @select_registered_customer_optional.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Cliente Registrado (Opcional)'**
  String get select_registered_customer_optional;

  /// No description provided for @new_customer_manual.
  ///
  /// In es, this message translates to:
  /// **'Cliente Nuevo / Ingresar Manualmente'**
  String get new_customer_manual;

  /// No description provided for @full_name.
  ///
  /// In es, this message translates to:
  /// **'Nombre Completo'**
  String get full_name;

  /// No description provided for @full_name_required.
  ///
  /// In es, this message translates to:
  /// **'Nombre Completo *'**
  String get full_name_required;

  /// No description provided for @phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get phone;

  /// No description provided for @plate_required.
  ///
  /// In es, this message translates to:
  /// **'Placa *'**
  String get plate_required;

  /// No description provided for @plate_hint.
  ///
  /// In es, this message translates to:
  /// **'ABC-123'**
  String get plate_hint;

  /// No description provided for @model_brand.
  ///
  /// In es, this message translates to:
  /// **'Modelo / Marca'**
  String get model_brand;

  /// No description provided for @model_brand_hint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Toyota Hilux 2021'**
  String get model_brand_hint;

  /// No description provided for @service_type_job.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Servicio / Trabajo'**
  String get service_type_job;

  /// No description provided for @symptoms_notes.
  ///
  /// In es, this message translates to:
  /// **'Notas / Síntomas reportados'**
  String get symptoms_notes;

  /// No description provided for @symptoms_notes_hint.
  ///
  /// In es, this message translates to:
  /// **'Detalles del cliente o sospecha técnica...'**
  String get symptoms_notes_hint;

  /// No description provided for @inventory_tab.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get inventory_tab;

  /// No description provided for @sale_price.
  ///
  /// In es, this message translates to:
  /// **'PRECIO VENTA'**
  String get sale_price;

  /// No description provided for @cost_price.
  ///
  /// In es, this message translates to:
  /// **'COSTO COMPRA'**
  String get cost_price;

  /// No description provided for @valuation.
  ///
  /// In es, this message translates to:
  /// **'VALUACIÓN'**
  String get valuation;

  /// No description provided for @add_batch_btn.
  ///
  /// In es, this message translates to:
  /// **'Lote'**
  String get add_batch_btn;

  /// No description provided for @batch_entry.
  ///
  /// In es, this message translates to:
  /// **'Ingresar Lote'**
  String get batch_entry;

  /// No description provided for @new_product.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Repuesto'**
  String get new_product;

  /// No description provided for @register_new_product.
  ///
  /// In es, this message translates to:
  /// **'Registrar Nuevo Repuesto'**
  String get register_new_product;

  /// No description provided for @search_product_hint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por SKU, nombre o categoría...'**
  String get search_product_hint;

  /// No description provided for @product_registered_success.
  ///
  /// In es, this message translates to:
  /// **'Repuesto registrado exitosamente en el catálogo'**
  String get product_registered_success;

  /// No description provided for @sku_code.
  ///
  /// In es, this message translates to:
  /// **'Código SKU'**
  String get sku_code;

  /// No description provided for @sku_required.
  ///
  /// In es, this message translates to:
  /// **'Código SKU *'**
  String get sku_required;

  /// No description provided for @sku_hint.
  ///
  /// In es, this message translates to:
  /// **'Ej. FLT-AIR-22'**
  String get sku_hint;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @category_required.
  ///
  /// In es, this message translates to:
  /// **'Categoría *'**
  String get category_required;

  /// No description provided for @part_description.
  ///
  /// In es, this message translates to:
  /// **'Descripción / Nombre del Repuesto'**
  String get part_description;

  /// No description provided for @part_name_required.
  ///
  /// In es, this message translates to:
  /// **'Descripción / Nombre del Repuesto *'**
  String get part_name_required;

  /// No description provided for @part_name_hint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Filtro de Aire Mann C25114'**
  String get part_name_hint;

  /// No description provided for @sale_price_required.
  ///
  /// In es, this message translates to:
  /// **'Precio Venta (S/) *'**
  String get sale_price_required;

  /// No description provided for @cost_price_required.
  ///
  /// In es, this message translates to:
  /// **'Costo Compra (S/) *'**
  String get cost_price_required;

  /// No description provided for @initial_stock_required.
  ///
  /// In es, this message translates to:
  /// **'Stock Inicial *'**
  String get initial_stock_required;

  /// No description provided for @min_alert_stock.
  ///
  /// In es, this message translates to:
  /// **'Alerta Mínima *'**
  String get min_alert_stock;

  /// No description provided for @compatibility_notes.
  ///
  /// In es, this message translates to:
  /// **'Aplicación / Compatibilidad (Opcional)'**
  String get compatibility_notes;

  /// No description provided for @compatibility_notes_hint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Compatible con motores 1.5L Toyota 2NR-FE...'**
  String get compatibility_notes_hint;

  /// No description provided for @batch_number.
  ///
  /// In es, this message translates to:
  /// **'Número de Lote / Factura'**
  String get batch_number;

  /// No description provided for @batch_invoice_number.
  ///
  /// In es, this message translates to:
  /// **'Número de Lote / Factura *'**
  String get batch_invoice_number;

  /// No description provided for @supplier_name.
  ///
  /// In es, this message translates to:
  /// **'Proveedor / Distribuidor'**
  String get supplier_name;

  /// No description provided for @supplier_distributor.
  ///
  /// In es, this message translates to:
  /// **'Proveedor / Distribuidor *'**
  String get supplier_distributor;

  /// No description provided for @quantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get quantity;

  /// No description provided for @quantity_with_unit.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get quantity_with_unit;

  /// No description provided for @unit_cost.
  ///
  /// In es, this message translates to:
  /// **'Costo Unit. (S/)'**
  String get unit_cost;

  /// No description provided for @unit_cost_currency.
  ///
  /// In es, this message translates to:
  /// **'Costo Unit. (S/) *'**
  String get unit_cost_currency;

  /// No description provided for @telemetry_tab.
  ///
  /// In es, this message translates to:
  /// **'Telemetría'**
  String get telemetry_tab;

  /// No description provided for @dtc_alerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas DTC / OBD-II'**
  String get dtc_alerts;

  /// No description provided for @live_telemetry.
  ///
  /// In es, this message translates to:
  /// **'Último Snapshot'**
  String get live_telemetry;

  /// No description provided for @mark_resolved.
  ///
  /// In es, this message translates to:
  /// **'Marcar Resuelto'**
  String get mark_resolved;

  /// No description provided for @freeze_frame.
  ///
  /// In es, this message translates to:
  /// **'Freeze Frame'**
  String get freeze_frame;

  /// No description provided for @dtc_resolved_success.
  ///
  /// In es, this message translates to:
  /// **'Código DTC marcado como RESUELTO'**
  String get dtc_resolved_success;

  /// No description provided for @billing_title.
  ///
  /// In es, this message translates to:
  /// **'Pagos y Cotizaciones'**
  String get billing_title;

  /// No description provided for @vouchers.
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get vouchers;

  /// No description provided for @quotes.
  ///
  /// In es, this message translates to:
  /// **'Cotizaciones'**
  String get quotes;

  /// No description provided for @client_data.
  ///
  /// In es, this message translates to:
  /// **'DATOS DEL ADQUIRIENTE / CLIENTE'**
  String get client_data;

  /// No description provided for @client_name.
  ///
  /// In es, this message translates to:
  /// **'Cliente / Razón Social'**
  String get client_name;

  /// No description provided for @document.
  ///
  /// In es, this message translates to:
  /// **'Documento (DNI/RUC)'**
  String get document;

  /// No description provided for @subtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal (Gravada)'**
  String get subtotal;

  /// No description provided for @igv.
  ///
  /// In es, this message translates to:
  /// **'I.G.V. (18%)'**
  String get igv;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total a Pagar'**
  String get total;

  /// No description provided for @pay.
  ///
  /// In es, this message translates to:
  /// **'COBRAR'**
  String get pay;

  /// No description provided for @thermal_ticket.
  ///
  /// In es, this message translates to:
  /// **'TICKET TÉRMICO'**
  String get thermal_ticket;

  /// No description provided for @pdf_sunat.
  ///
  /// In es, this message translates to:
  /// **'PDF SUNAT'**
  String get pdf_sunat;

  /// No description provided for @emit_voucher_action.
  ///
  /// In es, this message translates to:
  /// **'EMITIR COMPROBANTE'**
  String get emit_voucher_action;

  /// No description provided for @vouchers_all.
  ///
  /// In es, this message translates to:
  /// **'Todos los Comprobantes'**
  String get vouchers_all;

  /// No description provided for @boletas_filter.
  ///
  /// In es, this message translates to:
  /// **'Boletas (B001)'**
  String get boletas_filter;

  /// No description provided for @facturas_filter.
  ///
  /// In es, this message translates to:
  /// **'Facturas (F001)'**
  String get facturas_filter;

  /// No description provided for @boleta_venta.
  ///
  /// In es, this message translates to:
  /// **'Boleta de Venta (B001)'**
  String get boleta_venta;

  /// No description provided for @factura.
  ///
  /// In es, this message translates to:
  /// **'Factura (F001)'**
  String get factura;

  /// No description provided for @liquidation_billing_title.
  ///
  /// In es, this message translates to:
  /// **'Liquidación y Facturación SUNAT'**
  String get liquidation_billing_title;

  /// No description provided for @payment_recorded_success.
  ///
  /// In es, this message translates to:
  /// **'¡Cobro registrado exitosamente!'**
  String get payment_recorded_success;

  /// No description provided for @voucher_detail.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Comprobante'**
  String get voucher_detail;

  /// No description provided for @doc_label.
  ///
  /// In es, this message translates to:
  /// **'Doc.'**
  String get doc_label;

  /// No description provided for @dni_doc.
  ///
  /// In es, this message translates to:
  /// **'DNI'**
  String get dni_doc;

  /// No description provided for @ruc_doc.
  ///
  /// In es, this message translates to:
  /// **'RUC'**
  String get ruc_doc;

  /// No description provided for @ce_doc.
  ///
  /// In es, this message translates to:
  /// **'CE'**
  String get ce_doc;

  /// No description provided for @doc_number_prefix.
  ///
  /// In es, this message translates to:
  /// **'Número de'**
  String get doc_number_prefix;

  /// No description provided for @legal_name_or_full_name.
  ///
  /// In es, this message translates to:
  /// **'Razón Social / Nombre Completo'**
  String get legal_name_or_full_name;

  /// No description provided for @fiscal_address.
  ///
  /// In es, this message translates to:
  /// **'Dirección Fiscal (Lima)'**
  String get fiscal_address;

  /// No description provided for @profile_title.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil de Taller'**
  String get profile_title;

  /// No description provided for @personal_info.
  ///
  /// In es, this message translates to:
  /// **'Información Personal'**
  String get personal_info;

  /// No description provided for @edit_profile.
  ///
  /// In es, this message translates to:
  /// **'EDITAR DATOS PERSONALES'**
  String get edit_profile;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'CERRAR SESIÓN DEL TALLER'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la Aplicación'**
  String get language;

  /// No description provided for @first_name.
  ///
  /// In es, this message translates to:
  /// **'Nombres'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get last_name;

  /// No description provided for @mobile_phone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono Móvil'**
  String get mobile_phone;

  /// No description provided for @logout_dialog_title.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout_dialog_title;

  /// No description provided for @logout_upper.
  ///
  /// In es, this message translates to:
  /// **'CERRAR SESIÓN'**
  String get logout_upper;

  /// No description provided for @spanish_pe.
  ///
  /// In es, this message translates to:
  /// **'Español (Perú)'**
  String get spanish_pe;

  /// No description provided for @english_us.
  ///
  /// In es, this message translates to:
  /// **'English (US)'**
  String get english_us;

  /// No description provided for @tooltip_customer_directory.
  ///
  /// In es, this message translates to:
  /// **'Directorio de Clientes B2B'**
  String get tooltip_customer_directory;

  /// No description provided for @tooltip_billing.
  ///
  /// In es, this message translates to:
  /// **'Pagos y Cotizaciones'**
  String get tooltip_billing;

  /// No description provided for @tooltip_change_branch.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de Sede'**
  String get tooltip_change_branch;

  /// No description provided for @tooltip_refresh_kpis.
  ///
  /// In es, this message translates to:
  /// **'Refrescar KPIs'**
  String get tooltip_refresh_kpis;

  /// No description provided for @tooltip_refresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get tooltip_refresh;

  /// No description provided for @tooltip_refresh_orders.
  ///
  /// In es, this message translates to:
  /// **'Refrescar OTs'**
  String get tooltip_refresh_orders;

  /// No description provided for @tooltip_refresh_sensors.
  ///
  /// In es, this message translates to:
  /// **'Refrescar Sensores'**
  String get tooltip_refresh_sensors;

  /// No description provided for @tooltip_profile.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil de Taller / Cerrar Sesión'**
  String get tooltip_profile;

  /// No description provided for @tooltip_create_branch.
  ///
  /// In es, this message translates to:
  /// **'Crear Nueva Sede'**
  String get tooltip_create_branch;

  /// No description provided for @tooltip_share_whatsapp.
  ///
  /// In es, this message translates to:
  /// **'Compartir por WhatsApp'**
  String get tooltip_share_whatsapp;

  /// No description provided for @tooltip_start_task.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Tarea'**
  String get tooltip_start_task;

  /// No description provided for @tooltip_complete_task.
  ///
  /// In es, this message translates to:
  /// **'Marcar como Completada'**
  String get tooltip_complete_task;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @search_hint.
  ///
  /// In es, this message translates to:
  /// **'Buscar...'**
  String get search_hint;

  /// No description provided for @open_ot_bay.
  ///
  /// In es, this message translates to:
  /// **'Abrir OT en Bahía'**
  String get open_ot_bay;

  /// No description provided for @auth_welcome_title.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de vuelta'**
  String get auth_welcome_title;

  /// No description provided for @auth_welcome_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión con tu cuenta de cliente, técnico o administrador.'**
  String get auth_welcome_subtitle;

  /// No description provided for @auth_sign_in_btn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get auth_sign_in_btn;

  /// No description provided for @auth_no_account.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get auth_no_account;

  /// No description provided for @auth_create_account.
  ///
  /// In es, this message translates to:
  /// **'Regístrate aquí'**
  String get auth_create_account;

  /// No description provided for @auth_footer_roles.
  ///
  /// In es, this message translates to:
  /// **'Clientes · Técnicos · Administradores'**
  String get auth_footer_roles;

  /// No description provided for @auth_email_required.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico'**
  String get auth_email_required;

  /// No description provided for @auth_email_invalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo electrónico válido'**
  String get auth_email_invalid;

  /// No description provided for @auth_password_required.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get auth_password_required;

  /// No description provided for @auth_password_min.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get auth_password_min;

  /// No description provided for @auth_password_policy.
  ///
  /// In es, this message translates to:
  /// **'Debe incluir mayúscula, número y carácter especial'**
  String get auth_password_policy;

  /// No description provided for @forgot_title.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get forgot_title;

  /// No description provided for @forgot_step1_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo registrado para recibir un token de recuperación.'**
  String get forgot_step1_subtitle;

  /// No description provided for @forgot_send_btn.
  ///
  /// In es, this message translates to:
  /// **'Enviar código de recuperación'**
  String get forgot_send_btn;

  /// No description provided for @forgot_step2_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el token enviado a tu correo y define tu nueva contraseña.'**
  String get forgot_step2_subtitle;

  /// No description provided for @forgot_token_label.
  ///
  /// In es, this message translates to:
  /// **'Token de recuperación'**
  String get forgot_token_label;

  /// No description provided for @forgot_token_hint.
  ///
  /// In es, this message translates to:
  /// **'Pega el token recibido por correo'**
  String get forgot_token_hint;

  /// No description provided for @forgot_token_required.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el token de recuperación'**
  String get forgot_token_required;

  /// No description provided for @forgot_new_password_label.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get forgot_new_password_label;

  /// No description provided for @forgot_reset_btn.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get forgot_reset_btn;

  /// No description provided for @forgot_success_msg.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada. Ya puedes iniciar sesión.'**
  String get forgot_success_msg;

  /// No description provided for @register_title.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta de cliente'**
  String get register_title;

  /// No description provided for @register_step1_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo electrónico mediante un código OTP de 6 dígitos.'**
  String get register_step1_subtitle;

  /// No description provided for @register_send_otp_btn.
  ///
  /// In es, this message translates to:
  /// **'Enviar código OTP'**
  String get register_send_otp_btn;

  /// No description provided for @register_step2_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de 6 dígitos enviado a tu correo.'**
  String get register_step2_subtitle;

  /// No description provided for @register_otp_label.
  ///
  /// In es, this message translates to:
  /// **'Código OTP (6 dígitos)'**
  String get register_otp_label;

  /// No description provided for @register_otp_required.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de 6 dígitos'**
  String get register_otp_required;

  /// No description provided for @register_verify_otp_btn.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get register_verify_otp_btn;

  /// No description provided for @register_resend_otp.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get register_resend_otp;

  /// No description provided for @register_step3_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Correo verificado. Crea una contraseña segura para tu cuenta.'**
  String get register_step3_subtitle;

  /// No description provided for @register_confirm_password_label.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get register_confirm_password_label;

  /// No description provided for @register_password_mismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get register_password_mismatch;

  /// No description provided for @register_submit_btn.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get register_submit_btn;

  /// No description provided for @customer_portal_title.
  ///
  /// In es, this message translates to:
  /// **'ShiftIQ Cliente'**
  String get customer_portal_title;

  /// No description provided for @role_customer_badge.
  ///
  /// In es, this message translates to:
  /// **'CUENTA CLIENTE'**
  String get role_customer_badge;

  /// No description provided for @customer_welcome_title.
  ///
  /// In es, this message translates to:
  /// **'Tu taller conectado'**
  String get customer_welcome_title;

  /// No description provided for @customer_welcome_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Consulta el estado de tus vehículos, citas programadas y órdenes de servicio.'**
  String get customer_welcome_subtitle;

  /// No description provided for @customer_services_section.
  ///
  /// In es, this message translates to:
  /// **'TUS MÓDULOS DE CLIENTE'**
  String get customer_services_section;

  /// No description provided for @customer_vehicles_title.
  ///
  /// In es, this message translates to:
  /// **'Mis Vehículos'**
  String get customer_vehicles_title;

  /// No description provided for @customer_vehicles_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Historial técnico y alertas de diagnóstico OBD2'**
  String get customer_vehicles_subtitle;

  /// No description provided for @customer_appointments_title.
  ///
  /// In es, this message translates to:
  /// **'Mis Citas'**
  String get customer_appointments_title;

  /// No description provided for @customer_appointments_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Agenda y seguimiento de atención en sede'**
  String get customer_appointments_subtitle;

  /// No description provided for @customer_orders_title.
  ///
  /// In es, this message translates to:
  /// **'Órdenes y Cotizaciones'**
  String get customer_orders_title;

  /// No description provided for @customer_orders_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa avances, aprobaciones y comprobantes'**
  String get customer_orders_subtitle;

  /// No description provided for @customer_logout_confirm.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas cerrar tu sesión actual?'**
  String get customer_logout_confirm;

  /// No description provided for @org_active_branch.
  ///
  /// In es, this message translates to:
  /// **'Organización y Sede Activa'**
  String get org_active_branch;

  /// No description provided for @assigned_branch.
  ///
  /// In es, this message translates to:
  /// **'Sede Asignada'**
  String get assigned_branch;

  /// No description provided for @active_branch_label.
  ///
  /// In es, this message translates to:
  /// **'Sede Activa'**
  String get active_branch_label;

  /// No description provided for @specialty_label.
  ///
  /// In es, this message translates to:
  /// **'Especialidad'**
  String get specialty_label;

  /// No description provided for @base_salary_label.
  ///
  /// In es, this message translates to:
  /// **'Salario Base'**
  String get base_salary_label;

  /// No description provided for @security_section.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security_section;

  /// No description provided for @biometric_fingerprint_title.
  ///
  /// In es, this message translates to:
  /// **'Ingreso con huella digital'**
  String get biometric_fingerprint_title;

  /// No description provided for @biometric_face_title.
  ///
  /// In es, this message translates to:
  /// **'Ingreso con reconocimiento facial'**
  String get biometric_face_title;

  /// No description provided for @biometric_both_title.
  ///
  /// In es, this message translates to:
  /// **'Ingreso con huella o rostro'**
  String get biometric_both_title;

  /// No description provided for @biometric_default_title.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo biométrico'**
  String get biometric_default_title;

  /// No description provided for @biometric_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitar verificación al abrir la aplicación'**
  String get biometric_subtitle;

  /// No description provided for @biometric_enabled_toast.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo biométrico activado'**
  String get biometric_enabled_toast;

  /// No description provided for @biometric_disabled_toast.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo biométrico desactivado'**
  String get biometric_disabled_toast;

  /// No description provided for @biometric_error_toast.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar la biometría.'**
  String get biometric_error_toast;

  /// No description provided for @workshop_settings_title.
  ///
  /// In es, this message translates to:
  /// **'Configuración del Taller'**
  String get workshop_settings_title;

  /// No description provided for @services_catalog_title.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de Servicios'**
  String get services_catalog_title;

  /// No description provided for @services_catalog_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar servicios y tarifas de la sede'**
  String get services_catalog_subtitle;

  /// No description provided for @workshop_branches_title.
  ///
  /// In es, this message translates to:
  /// **'Sedes del Taller'**
  String get workshop_branches_title;

  /// No description provided for @workshop_branches_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar o administrar sedes activas'**
  String get workshop_branches_subtitle;

  /// No description provided for @badge_owner_admin.
  ///
  /// In es, this message translates to:
  /// **'DUEÑO / ADMIN'**
  String get badge_owner_admin;

  /// No description provided for @badge_workshop_staff.
  ///
  /// In es, this message translates to:
  /// **'PERSONAL TALLER'**
  String get badge_workshop_staff;

  /// No description provided for @switch_branch_title.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de sede'**
  String get switch_branch_title;

  /// No description provided for @view_on_map.
  ///
  /// In es, this message translates to:
  /// **'Ver en mapa'**
  String get view_on_map;

  /// No description provided for @no_branches_available.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron sedes disponibles.'**
  String get no_branches_available;

  /// No description provided for @network_prefix.
  ///
  /// In es, this message translates to:
  /// **'Red'**
  String get network_prefix;

  /// No description provided for @billing_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Pagos y cotizaciones del taller'**
  String get billing_subtitle;

  /// No description provided for @today_collections.
  ///
  /// In es, this message translates to:
  /// **'Cobros Hoy'**
  String get today_collections;

  /// No description provided for @pending_collections.
  ///
  /// In es, this message translates to:
  /// **'Por Cobrar'**
  String get pending_collections;

  /// No description provided for @payments_count_suffix.
  ///
  /// In es, this message translates to:
  /// **'pagos'**
  String get payments_count_suffix;

  /// No description provided for @no_vouchers_title.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron comprobantes emitidos'**
  String get no_vouchers_title;

  /// No description provided for @no_vouchers_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Desliza hacia abajo para actualizar o registra un cobro'**
  String get no_vouchers_subtitle;

  /// No description provided for @no_quotes_title.
  ///
  /// In es, this message translates to:
  /// **'No hay cotizaciones registradas'**
  String get no_quotes_title;

  /// No description provided for @pull_to_refresh_hint.
  ///
  /// In es, this message translates to:
  /// **'Desliza hacia abajo para actualizar'**
  String get pull_to_refresh_hint;

  /// No description provided for @services_catalog_subtitle_page.
  ///
  /// In es, this message translates to:
  /// **'Servicios de mano de obra de la sede'**
  String get services_catalog_subtitle_page;

  /// No description provided for @new_service.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Servicio'**
  String get new_service;

  /// No description provided for @edit_service.
  ///
  /// In es, this message translates to:
  /// **'Editar Servicio'**
  String get edit_service;

  /// No description provided for @service_name_label.
  ///
  /// In es, this message translates to:
  /// **'Nombre del servicio *'**
  String get service_name_label;

  /// No description provided for @service_price_label.
  ///
  /// In es, this message translates to:
  /// **'Precio (S/) *'**
  String get service_price_label;

  /// No description provided for @save_service.
  ///
  /// In es, this message translates to:
  /// **'Guardar Servicio'**
  String get save_service;

  /// No description provided for @update_service.
  ///
  /// In es, this message translates to:
  /// **'Actualizar Servicio'**
  String get update_service;

  /// No description provided for @no_services_title.
  ///
  /// In es, this message translates to:
  /// **'Sin servicios registrados'**
  String get no_services_title;

  /// No description provided for @no_services_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea los servicios que ofrece esta sede para usarlos al agendar citas'**
  String get no_services_subtitle;

  /// No description provided for @biometric_lock_title.
  ///
  /// In es, this message translates to:
  /// **'Sesión Protegida'**
  String get biometric_lock_title;

  /// No description provided for @biometric_use_another_account.
  ///
  /// In es, this message translates to:
  /// **'Usar otra cuenta'**
  String get biometric_use_another_account;

  /// No description provided for @biometric_verifying.
  ///
  /// In es, this message translates to:
  /// **'Verificando...'**
  String get biometric_verifying;

  /// No description provided for @biometric_unlock_fingerprint.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con Huella Digital'**
  String get biometric_unlock_fingerprint;

  /// No description provided for @biometric_unlock_face.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con Rostro'**
  String get biometric_unlock_face;

  /// No description provided for @biometric_unlock_both.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear con Huella / Rostro'**
  String get biometric_unlock_both;

  /// No description provided for @biometric_optin_title.
  ///
  /// In es, this message translates to:
  /// **'¿Activar ingreso rápido?'**
  String get biometric_optin_title;

  /// No description provided for @biometric_not_now.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get biometric_not_now;

  /// No description provided for @customer_tab_summary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get customer_tab_summary;

  /// No description provided for @customer_tab_vehicles.
  ///
  /// In es, this message translates to:
  /// **'Vehículos'**
  String get customer_tab_vehicles;

  /// No description provided for @customer_tab_orders.
  ///
  /// In es, this message translates to:
  /// **'Órdenes'**
  String get customer_tab_orders;

  /// No description provided for @customer_tab_payments.
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get customer_tab_payments;

  /// No description provided for @customer_vehicles_header_sub.
  ///
  /// In es, this message translates to:
  /// **'Tus vehículos y diagnóstico OBD-II'**
  String get customer_vehicles_header_sub;

  /// No description provided for @customer_orders_header_sub.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento de órdenes en taller'**
  String get customer_orders_header_sub;

  /// No description provided for @customer_payments_header_sub.
  ///
  /// In es, this message translates to:
  /// **'Aprobación de presupuestos y pagos'**
  String get customer_payments_header_sub;

  /// No description provided for @no_active_orders_branch.
  ///
  /// In es, this message translates to:
  /// **'No hay órdenes activas en esta sede.'**
  String get no_active_orders_branch;

  /// No description provided for @general_inspection.
  ///
  /// In es, this message translates to:
  /// **'Revisión general'**
  String get general_inspection;

  /// No description provided for @stock_restock_needed.
  ///
  /// In es, this message translates to:
  /// **'Stock por reponer'**
  String get stock_restock_needed;

  /// No description provided for @stock_healthy.
  ///
  /// In es, this message translates to:
  /// **'Stock saludable'**
  String get stock_healthy;

  /// No description provided for @obd2_review_needed.
  ///
  /// In es, this message translates to:
  /// **'Revisión OBD-II'**
  String get obd2_review_needed;

  /// No description provided for @telemetry_stable.
  ///
  /// In es, this message translates to:
  /// **'Telemetría estable'**
  String get telemetry_stable;

  /// No description provided for @new_work_order_short.
  ///
  /// In es, this message translates to:
  /// **'Nueva OT'**
  String get new_work_order_short;

  /// No description provided for @schedule_appointment_short.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get schedule_appointment_short;

  /// No description provided for @batch_entry_short.
  ///
  /// In es, this message translates to:
  /// **'Ingreso lote'**
  String get batch_entry_short;

  /// No description provided for @revenue_title.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get revenue_title;

  /// No description provided for @no_revenue_movements.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos registrados'**
  String get no_revenue_movements;

  /// No description provided for @operational_activity.
  ///
  /// In es, this message translates to:
  /// **'Actividad operativa'**
  String get operational_activity;

  /// No description provided for @work_orders_short.
  ///
  /// In es, this message translates to:
  /// **'OTs'**
  String get work_orders_short;

  /// No description provided for @no_activity_recorded.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad registrada'**
  String get no_activity_recorded;

  /// No description provided for @weekly_productivity.
  ///
  /// In es, this message translates to:
  /// **'Productividad Semanal'**
  String get weekly_productivity;

  /// No description provided for @tasks_completed_7d.
  ///
  /// In es, this message translates to:
  /// **'tareas completadas en 7 días'**
  String get tasks_completed_7d;

  /// No description provided for @task_completed_7d.
  ///
  /// In es, this message translates to:
  /// **'tarea completada en 7 días'**
  String get task_completed_7d;

  /// No description provided for @task_singular.
  ///
  /// In es, this message translates to:
  /// **'tarea'**
  String get task_singular;

  /// No description provided for @tasks_plural.
  ///
  /// In es, this message translates to:
  /// **'tareas'**
  String get tasks_plural;

  /// No description provided for @bay_status_title.
  ///
  /// In es, this message translates to:
  /// **'Estado en Bahía'**
  String get bay_status_title;

  /// No description provided for @no_tasks_registered_yet.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas registradas aún'**
  String get no_tasks_registered_yet;

  /// No description provided for @task_assigned_singular.
  ///
  /// In es, this message translates to:
  /// **'tarea asignada'**
  String get task_assigned_singular;

  /// No description provided for @tasks_in_queue_plural.
  ///
  /// In es, this message translates to:
  /// **'tareas en tu cola'**
  String get tasks_in_queue_plural;

  /// No description provided for @completed_status.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get completed_status;

  /// No description provided for @completed_plural.
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get completed_plural;

  /// No description provided for @in_progress_status.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get in_progress_status;

  /// No description provided for @pending_plural.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get pending_plural;

  /// No description provided for @progress_by_order.
  ///
  /// In es, this message translates to:
  /// **'Avance por Orden'**
  String get progress_by_order;

  /// No description provided for @ready_short.
  ///
  /// In es, this message translates to:
  /// **'Listas'**
  String get ready_short;

  /// No description provided for @pending_short.
  ///
  /// In es, this message translates to:
  /// **'Pend.'**
  String get pending_short;

  /// No description provided for @add_vehicle.
  ///
  /// In es, this message translates to:
  /// **'Agregar vehículo'**
  String get add_vehicle;

  /// No description provided for @add_vehicle_title.
  ///
  /// In es, this message translates to:
  /// **'Registrar Nuevo Vehículo'**
  String get add_vehicle_title;

  /// No description provided for @vehicle_plate_label.
  ///
  /// In es, this message translates to:
  /// **'Placa *'**
  String get vehicle_plate_label;

  /// No description provided for @vehicle_brand_label.
  ///
  /// In es, this message translates to:
  /// **'Marca *'**
  String get vehicle_brand_label;

  /// No description provided for @vehicle_model_label.
  ///
  /// In es, this message translates to:
  /// **'Modelo *'**
  String get vehicle_model_label;

  /// No description provided for @vehicle_year_label.
  ///
  /// In es, this message translates to:
  /// **'Año *'**
  String get vehicle_year_label;

  /// No description provided for @vehicle_vin_label.
  ///
  /// In es, this message translates to:
  /// **'VIN (17 caracteres) *'**
  String get vehicle_vin_label;

  /// No description provided for @vehicle_vin_error.
  ///
  /// In es, this message translates to:
  /// **'El VIN debe tener exactamente 17 caracteres'**
  String get vehicle_vin_error;

  /// No description provided for @vehicle_year_error.
  ///
  /// In es, this message translates to:
  /// **'Ingrese un año válido'**
  String get vehicle_year_error;

  /// No description provided for @vehicle_save_btn.
  ///
  /// In es, this message translates to:
  /// **'Guardar Vehículo'**
  String get vehicle_save_btn;

  /// No description provided for @vehicle_registered_success.
  ///
  /// In es, this message translates to:
  /// **'Vehículo registrado correctamente'**
  String get vehicle_registered_success;

  /// No description provided for @no_vehicles_title.
  ///
  /// In es, this message translates to:
  /// **'Sin vehículos registrados'**
  String get no_vehicles_title;

  /// No description provided for @no_vehicles_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tu vehículo para ver aquí su telemetría OBD-II, alertas DTC e historial en taller.'**
  String get no_vehicles_subtitle;
}

class _AppLocalizationsGenDelegate
    extends LocalizationsDelegate<AppLocalizationsGen> {
  const _AppLocalizationsGenDelegate();

  @override
  Future<AppLocalizationsGen> load(Locale locale) {
    return SynchronousFuture<AppLocalizationsGen>(
      lookupAppLocalizationsGen(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsGenDelegate old) => false;
}

AppLocalizationsGen lookupAppLocalizationsGen(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsGenEn();
    case 'es':
      return AppLocalizationsGenEs();
  }

  throw FlutterError(
    'AppLocalizationsGen.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
