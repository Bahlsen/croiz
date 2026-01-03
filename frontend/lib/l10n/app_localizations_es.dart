// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Bienvenido a Croiz';

  @override
  String get puzzles => 'Puzzles';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageUkrainian => 'Ucraniano';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get selectAWord => 'Selecciona una palabra';

  @override
  String get menu => 'Menú';

  @override
  String get clear => 'Limpiar';

  @override
  String get close => 'Cerrar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get view => 'Ver';

  @override
  String get reveal => 'Revelar';

  @override
  String get revealLetterOption => 'Revelar letra';

  @override
  String get revealWordOption => 'Revelar palabra';

  @override
  String get revealAllOption => 'Revelar todo';

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String get loading => 'Cargando...';

  @override
  String get clearIncorrectLetters => 'Limpiar letras incorrectas';

  @override
  String get switchKeyboardLayout => 'Cambiar teclado';

  @override
  String letterLabel(Object letter) {
    return 'Letra $letter';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get home => 'Inicio';

  @override
  String get keyboardSizeLabel => 'Tamaño del teclado';

  @override
  String get keyboardStyle => 'Estilo del teclado';

  @override
  String get muteSounds => 'Silenciar sonidos';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get loadingPuzzle => 'Cargando puzzle...';

  @override
  String get pleaseWait => 'Por favor espere';

  @override
  String get errorLoading => 'Error al cargar el puzzle';

  @override
  String get subtitle => 'Crucigramas';

  @override
  String get ready => '¡Listo!';

  @override
  String get loadingSounds => 'Cargando sonidos...';

  @override
  String get starting => 'Iniciando...';

  @override
  String get small => 'Pequeño';

  @override
  String get medium => 'Mediano';

  @override
  String get large => 'Grande';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Generador de Puzzles';

  @override
  String get topicLabel => 'Tema (ej. Ciencia, Viajes...)';

  @override
  String get topicHint => 'Introduce un tema';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get difficultyLabel => 'Dificultad';

  @override
  String get sizeLabel => 'Tamaño de cuadrícula';

  @override
  String get generateButton => 'GENERAR';

  @override
  String get generating => 'Generando...';

  @override
  String get successMessage => '¡Puzzle generado con éxito!';

  @override
  String get playButton => 'JUGAR';

  @override
  String get errorTopicMissing => 'Por favor introduce un tema';

  @override
  String get quick => 'Rápido';

  @override
  String get standard => 'Estándar';

  @override
  String get continuePlaying => 'Continuar Jugando';

  @override
  String get noPuzzlesInProgress => 'No hay puzzles en curso';

  @override
  String get across => 'Horizontal';

  @override
  String get down => 'Vertical';

  @override
  String get easy => 'Fácil';

  @override
  String get hard => 'Difícil';

  @override
  String get expert => 'Experto';

  @override
  String get pro => 'Pro';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Celda fila $row, columna $col';
  }

  @override
  String semanticCellNumber(Object number) {
    return 'número $number';
  }

  @override
  String semanticCellLetter(Object letter) {
    return 'letra $letter';
  }

  @override
  String get semanticCellEmpty => 'vacía';

  @override
  String get semanticCellSelected => 'seleccionada';

  @override
  String semanticClueAcross(Object clue) {
    return 'Horizontal: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Vertical: $clue';
  }

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get revealAllConfirmationTitle => 'Confirmar Revelar Todo';

  @override
  String get revealAllConfirmationMessage => '¿Estás seguro de que quieres revelar todo el crucigrama?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get completedFilter => 'Completado';

  @override
  String get deletePuzzle => 'Eliminar Crucigrama Generado';

  @override
  String get deletePuzzleConfirmation => '¿Estás seguro de que quieres eliminar este crucigrama? Esta acción no se puede deshacer.';

  @override
  String get deleteSuccessMessage => 'Puzzle eliminado con éxito';

  @override
  String get cancel => 'Cancelar';
}
