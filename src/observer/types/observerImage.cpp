#include "observerImage.h"
#include "terrameGlobals.h"

#include <QApplication>
#include <QDesktopWidget>

#include "imageGUI.h"
#include "decoder.h"
#include "observerMap.h"

#ifdef TME_BLACK_BOARD
	#include "blackBoard.h"
#endif

extern "C"
{
#include <lua.h>
}
#include "luna.h"


extern lua_State * L;
extern ExecutionModes execModes;

using namespace TerraMEObserver;

ObserverImage::ObserverImage (Subject *sub) : ObserverInterf(sub)
{
    obsImgGUI = new ImageGUI();

    observerType = TObsImage;
    subjectType = sub->getType(); // TO_DO: Changes it to Observer pattern

    mapAttributes = new QHash<QString, Attributes*>();

#ifdef TME_BLACK_BOARD
    protocolDecoder = NULL;
#else
    protocolDecoder = new Decoder();
#endif

    painterWidget = new PainterWidget(mapAttributes, observerType);
    //painterWidget->setOperatorMode(QPainter::CompositionMode_Multiply);
    //// painterWidget->setGeometry(0, 0, 1500, 1500);
    //// painterWidget->show();

    width = 0;
    height = 0;

    builtLegend = 0;
    legendWindow = 0;		// ponteiro para LegendWindow
    path = DEFAULT_NAME;

    disableSaveImage = false;
}

ObserverImage::~ObserverImage()
{
    foreach(Attributes *attrib, mapAttributes->values())
        delete attrib;
    delete mapAttributes; mapAttributes = 0;

    delete painterWidget; painterWidget = 0;
    delete legendWindow; legendWindow = 0;

    delete obsImgGUI; obsImgGUI = 0;
    delete protocolDecoder; protocolDecoder = 0;
}

#ifdef TME_BLACK_BOARD

bool ObserverImage::draw(QDataStream &state)
{
    bool drw = false;

    if (BlackBoard::getInstance().canDraw())
        drw = painterWidget->draw();

    if (/*decoded &&*/ legendWindow && (builtLegend < 1))
    {
        // painterWidget->draw();
        legendWindow->makeLegend();

        builtLegend++;
    }

    qApp->processEvents();
    return drw;
}

#else

bool ObserverImage::draw(QDataStream &state)
{
    bool decoded = false;
    QString msg;
    state >> msg;

    QList<Attributes *> listAttribs = mapAttributes->values();
    Attributes * attrib = 0;

    for (int i = 0; i < listAttribs.size(); i++)
    {
        attrib = listAttribs.at(i);
        if (attrib->getType() == TObsCell)
        {
            attrib->clear();
            // decoded = protocolDecoder->decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
            if (decoded)
                painterWidget->plotMap(attrib);
        }
        qApp->processEvents();
    }

    if (/*decoded &&*/ legendWindow && (builtLegend < 1))
    {
        legendWindow->makeLegend();

        // Verificar porque a primeira invocação do método plotMap
        // gera a imagem foreground totalmente preta. Assim, é preciso
        // repetir essa chamada aqui!
        painterWidget->replotMap();

        builtLegend++;
    }

    //if (! disableSaveImage)
    //    return save();

    return decoded;
}

#endif

QStringList ObserverImage::getAttributes()
{
    return attribList;
}

const TypesOfObservers ObserverImage::getType() const
{
    return observerType;
}

void ObserverImage::setPath(const QString & pth, const QString & prefix)
{
    if (pth.endsWith("/"))
        path = pth + prefix;
    else
        path = pth + "/" + prefix;

    obsImgGUI->setPath(pth, prefix);
    painterWidget->setPath(path);
}

void ObserverImage::setAttributes(QStringList &attribs, QStringList legKeys,
    QStringList legAttribs, TypesOfSubjects type)
{
    // lista com os atributos que serão observados
    //itemList = headers;
    if (attribList.isEmpty())
    {
        attribList << attribs;
    }
    else
    {
        foreach(const QString & str, attribs)
        {
            if (! attribList.contains(str))
                attribList.append(str);
        }
    }

#ifdef DEBUG_OBSERVER
    qDebug() << "\nheaders:\n" << headers;
    qDebug() << "\nitemList:\n" << itemList;
    qDebug() << "\nMapAttributes()->keys(): " << mapAttributes->keys() << "\n";

    qDebug() << "LEGEND_ITENS: " << LEGEND_ITENS;
    qDebug() << "num de legendas: " << (int) legKeys.size() / LEGEND_ITENS;

    for (int j = 0; j < legKeys.size(); j++)
        qDebug() << legKeys.at(j) << " = " << legAttrib.at(j);
#endif

    for (int j = 0; (legKeys.size() > 0 && j < LEGEND_KEYS.size()); j++)
    {
        if (legKeys.indexOf(LEGEND_KEYS.at(j)) < 0)
        {
            //qFatal("Error: Parameter legend \"%s\" not found. Please check it in the model.", qPrintable( LEGEND_KEYS.at(j) ) );
            //string err_out = string("Neighborhood '" ) + string (index) + string("' not found");
            lua_getglobal(L, "incompatibleTypesErrorMsg");
            lua_pushstring(L,LEGEND_KEYS.at(j).toLatin1().constData());
            lua_pushstring(L,"string");
            lua_pushstring(L,"nil");
            lua_pushnumber(L,3);
            lua_call(L,4,0);
        }
    }
    int dataType = 0, mode = 0, slices = 0, precision = 0, stdDeviation = 0, max = 0;
    int min = 0, colorBar = 0, font = 0, fontSize = 0, symbol = 0, width = 0;
    // int style = 0;

#ifdef TME_BLACK_BOARD
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if (subjAttr) 
        subjAttr->setSubjectType(getSubjectType());
#endif

    Attributes *attrib = 0;
    for( int i = 0; i < attribList.size(); i++)
    {
        if ((attribList.at(i) != "x") && (attribList.at(i) != "y")
            && (! mapAttributes->contains(attribList.at(i)) ) )
        {
            attrib = new Attributes(attribList.at(i), cellularSpaceSize.width(), 
                cellularSpaceSize.height(), type);

#ifdef TME_BLACK_BOARD
            attrib->setParentSubjectID(getSubjectId());
            attrib->setXsValue(subjAttr->getXs());
            attrib->setYsValue(subjAttr->getYs());
#endif
            
            obsAttrib.append(attribList.at(i));
            attrib->setVisible(true);

            //------- Recupera a legenda do arquivo e cria o objeto attrib
            if (! legKeys.isEmpty())
            {
                dataType = legKeys.indexOf(TYPE);
                mode = legKeys.indexOf(GROUP_MODE);
                slices = legKeys.indexOf(SLICES);
                precision = legKeys.indexOf(PRECISION);
                stdDeviation = legKeys.indexOf(STD_DEV);
                max = legKeys.indexOf(MAX);
                min = legKeys.indexOf(MIN);
                colorBar = legKeys.indexOf(COLOR_BAR);
                font = legKeys.indexOf(FONT_FAMILY);
                fontSize = legKeys.indexOf(FONT_SIZE);
                symbol = legKeys.indexOf(SYMBOL);
                width = legKeys.indexOf(WIDTH);
                // style = legKeys.indexOf(STYLE);

                attrib->setDataType( (TypesOfData) legAttribs.at(dataType).toInt());
                attrib->setGroupMode( (GroupingMode) legAttribs.at(mode).toInt());
                attrib->setSlices(legAttribs.at(slices).toInt() - 1);				// conta com o zero
                attrib->setPrecisionNumber(legAttribs.at(precision).toInt() - 1);	// conta com o zero
                attrib->setStdDeviation( (StdDev) legAttribs.at(stdDeviation).toInt());
                attrib->setMaxValue(legAttribs.at(max).toDouble());
                attrib->setMinValue(legAttribs.at(min).toDouble());

                bool ok = false;
                int value = 0;
                //Fonte
                attrib->setFontFamily(legAttribs.at(font));
                value = legAttribs.at(fontSize).toInt(&ok, false);
                if (ok)
                    attrib->setFontSize(value);
                else
                    attrib->setFontSize(12);

                //Converte o código ASCII do símbolo em caracter
                ok = false;
                value = legAttribs.at(symbol).toInt(&ok, 10);
                if (ok)
                    attrib->setSymbol( QString( QChar(value) ));
                else
                    attrib->setSymbol(legAttribs.at(symbol));
                
				attrib->setWidth(legAttribs.at(width).toDouble());

                std::vector<ColorBar> colorBarVec;
                std::vector<ColorBar> stdColorBarVec;
                QStringList labelList, valueList;

                ObserverMap::createColorsBar(legAttribs.at(colorBar),
                    colorBarVec, stdColorBarVec, valueList, labelList);

                attrib->setColorBar(colorBarVec);
                attrib->setStdColorBar(stdColorBarVec);
                attrib->setValueList(valueList);
                attrib->setLabelList(labelList);

                // Removes the legend items retrieved
                for(int j = 0; j < LEGEND_ITENS; j++)
                {
                    legKeys.removeFirst();
                    legAttribs.removeFirst();
                }

#ifdef DEBUG_OBSERVER
                qDebug() << "valueList.size(): " << valueList.size();
                qDebug() << valueList;
                qDebug() << "\nlabelList.size(): " << labelList.size();
                qDebug() << labelList;
                qDebug() << "\nattrib->toString()\n" << attrib->toString();
#endif
            }
            attrib->makeBkp();
            mapAttributes->insert(attribList.at(i), attrib);
        }
    }

    if (! legendWindow)
        legendWindow = new LegendWindow();
		
    legendWindow->setValues(mapAttributes, obsAttrib);
	painterWidget->updateAttributeList();
}

void ObserverImage::setCellSpaceSize(int w, int h)
{
    QRect deskRect = qApp->desktop()->screenGeometry(obsImgGUI);
    
    double widthAux = deskRect.width() / w;
    double heightAux = deskRect.height() / h;
    
    width = w;
    height = h;

    cellularSpaceSize = QSize(width * widthAux, height * widthAux);
    painterWidget->resize(cellularSpaceSize, QSize(widthAux, widthAux));
    needResizeImage = true;
}

bool ObserverImage::save()
{
    bool savingImages = false; //painterWidget->save(path);

    if (! savingImages)
    {
        obsImgGUI->setStatusMessage("Unable to save the image.");
        if (execModes != Quiet )
        {
			string str = string("Unable to save the image."
								"The path is incorrect or you do not have permission to perform this task.");
			lua_getglobal(L, "customWarningMsg");
			lua_pushstring(L,str.c_str());
			lua_pushnumber(L,5);
			lua_call(L,2,0);
        }
    }
    return savingImages;
}

PainterWidget * ObserverImage::getPainterWidget() const
{
    return painterWidget;
}

QHash<QString, Attributes*> * ObserverImage::getMapAttributes() const
{
    return mapAttributes;
}

Decoder & ObserverImage::getProtocolDecoder() const
{
    return *protocolDecoder;
}

const QSize & ObserverImage::getCellSpaceSize() const
{
    return cellularSpaceSize;
}

void ObserverImage::setDisableSaveImage()
{
    disableSaveImage = true;
}

bool ObserverImage::getDisableSaveImage() const
{
    return disableSaveImage;
}

int ObserverImage::close()
{
    obsImgGUI->close();
    painterWidget->close();
    return 0;
}

void ObserverImage::show()
{
    obsImgGUI->showNormal();
}
