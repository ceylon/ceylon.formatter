import org.antlr.runtime { Token }
import com.redhat.ceylon.compiler.typechecker.tree { Tree { MetaLiteral } }


// TODO
// remove assertions before release; they’re probably useful for finding bugs,
// but impact performance negatively


FormattingWriter.FormattingContext writeBacktickOpening(FormattingWriter writer, Token backtick) {
    assert (backtick.text == "`");
    value context = writer.writeToken {
        backtick;
        beforeToken = Indent(0);
        afterToken = noLineBreak;
        spaceBefore = 0;
        spaceAfter = false;
    };
    assert (exists context);
    return context;
}

void writeBacktickClosing(FormattingWriter writer, Token backtick, FormattingWriter.FormattingContext context) {
    assert (backtick.text == "`");
    writer.writeToken {
        backtick;
        beforeToken = noLineBreak;
        afterToken = Indent(0);
        spaceBefore = false;
        spaceAfter = 0;
        context;
    };
}

void writeEquals(FormattingWriter writer, Token|String equals) {
    if(is Token equals) {
        assert (equals.text == "=");
    } else {
        assert (equals == "=");
    }
    writer.writeToken {
        equals;
        beforeToken = noLineBreak;
        afterToken = Indent(1);
        spaceBefore = true;
        spaceAfter = true;
    };
}

"""Writes a meta literal, for example `` `class Object` `` (where [[start]] would be `"class"`)
   or `` `process` `` (where [[start]] would be [[null]])."""
see (`function writeMetaLiteralStart`)
void writeMetaLiteral(FormattingWriter writer, FormattingVisitor visitor, MetaLiteral that, String? start) {
    value context = writeBacktickOpening(writer, that.mainToken);
    if (exists start) {
        writeMetaLiteralStart(writer, start);
    }
    that.visitChildren(visitor);
    writeBacktickClosing(writer, that.mainEndToken, context);
}

"""Writes the start of a meta literal, for example the `class` or `module`
   of `` `class Object` `` or `` `module ceylon.language` ``."""
void writeMetaLiteralStart(FormattingWriter writer, String start) {
    writer.writeToken {
        start;
        beforeToken = noLineBreak;
        afterToken = Indent(1);
        spaceBefore = false;
        spaceAfter = true;
    };
}

void writeModifier(FormattingWriter writer, Token modifier) {
    writer.writeToken {
        modifier;
        beforeToken = noLineBreak;
        spaceBefore = true;
        spaceAfter = true;
    };
}

void writeSemicolon(FormattingWriter writer, Token semicolon, FormattingWriter.FormattingContext context) {
    assert(semicolon.text == ";");
    writer.writeToken {
        semicolon;
        beforeToken = noLineBreak;
        afterToken = Indent(0);
        spaceBefore = false;
        spaceAfter = true;
        context;
    };
}

"Write an optional `<` before `inner` and an optional `>` after.
 For grouped types (`{<String->String>*}`)."
void writeOptionallyGrouped(FormattingWriter writer, Anything() inner) {
    writer.writeToken {
        "<";
        afterToken = noLineBreak;
        spaceAfter = false;
        optional = true;
    };
    inner();
    writer.writeToken {
        ">";
        beforeToken = noLineBreak;
        spaceBefore = false;
        optional = true;
    };
}