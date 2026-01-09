// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Croiz';

  @override
  String get welcome => 'Bem-vindo ao Croiz';

  @override
  String get puzzles => 'Puzzles';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageUkrainian => 'Ucraniano';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get selectAWord => 'Selecionar uma palavra';

  @override
  String get menu => 'Menu';

  @override
  String get clear => 'Limpar';

  @override
  String get close => 'Fechar';

  @override
  String get restart => 'Reiniciar';

  @override
  String get view => 'Ver';

  @override
  String get reveal => 'Revelar';

  @override
  String get revealLetterOption => 'Revelar letra';

  @override
  String get revealWordOption => 'Revelar palavra';

  @override
  String get revealAllOption => 'Revelar tudo';

  @override
  String get congratulations => 'Parabéns!';

  @override
  String get loading => 'Carregando...';

  @override
  String get clearIncorrectLetters => 'Limpar letras incorretas';

  @override
  String get switchKeyboardLayout => 'Alterar layout do teclado';

  @override
  String letterLabel(Object letter) {
    return 'Letra $letter';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get home => 'Início';

  @override
  String get keyboardSizeLabel => 'Tamanho do teclado';

  @override
  String get keyboardStyle => 'Estilo do teclado';

  @override
  String get muteSounds => 'Sem som';

  @override
  String get darkTheme => 'Tema escuro';

  @override
  String get help => 'Ajuda';

  @override
  String get about => 'Sobre';

  @override
  String get loadingPuzzle => 'Carregando puzzle...';

  @override
  String get pleaseWait => 'Por favor aguarde';

  @override
  String get errorLoading => 'Erro ao carregar o puzzle';

  @override
  String get subtitle => 'Palavras Cruzadas';

  @override
  String get ready => 'Pronto!';

  @override
  String get loadingSounds => 'Carregando sons...';

  @override
  String get starting => 'Iniciando...';

  @override
  String get small => 'Pequeno';

  @override
  String get medium => 'Médio';

  @override
  String get large => 'Grande';

  @override
  String get azerty => 'AZERTY';

  @override
  String get qwerty => 'QWERTY';

  @override
  String get generatorTitle => 'Gerador de Puzzles';

  @override
  String get topicLabel => 'Tópico (ex: Ciência, Viagens...)';

  @override
  String get topicHint => 'Digite um tópico';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get difficultyLabel => 'Dificuldade';

  @override
  String get sizeLabel => 'Tamanho da grade';

  @override
  String get generateButton => 'GERAR';

  @override
  String get generating => 'Gerando...';

  @override
  String get successMessage => 'Puzzle gerado com sucesso!';

  @override
  String get playButton => 'JOGAR';

  @override
  String get errorTopicMissing => 'Por favor, digite um tópico';

  @override
  String get quick => 'Rápido';

  @override
  String get standard => 'Padrão';

  @override
  String get continuePlaying => 'Continuar jogando';

  @override
  String get noPuzzlesInProgress => 'Nenhum puzzle em andamento';

  @override
  String get across => 'Horizontal';

  @override
  String get down => 'Vertical';

  @override
  String get easy => 'Fácil';

  @override
  String get hard => 'Difícil';

  @override
  String get expert => 'Expert';

  @override
  String get pro => 'Pro';

  @override
  String semanticCellRowColumn(Object col, Object row) {
    return 'Célula linha $row, coluna $col';
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
  String get semanticCellEmpty => 'vazia';

  @override
  String get semanticCellSelected => 'selecionada';

  @override
  String semanticClueAcross(Object clue) {
    return 'Horizontal: $clue';
  }

  @override
  String semanticClueDown(Object clue) {
    return 'Vertical: $clue';
  }

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get revealAllConfirmationTitle => 'Confirmar Revelar Tudo';

  @override
  String get revealAllConfirmationMessage =>
      'Tem certeza de que deseja revelar todo o puzzle?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get completedFilter => 'Concluído';

  @override
  String get deletePuzzle => 'Excluir Puzzle Gerado';

  @override
  String get deletePuzzleConfirmation =>
      'Tem certeza de que deseja excluir este puzzle? Esta ação não pode ser desfeita.';

  @override
  String get deleteSuccessMessage => 'Puzzle excluído com sucesso';

  @override
  String get cancel => 'Cancelar';
}
