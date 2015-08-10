#include "observerImage.h"
#include <QApplication>
#include "terrameGlobals.h"

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L;

extern ExecutionModes execModes;


#include "image/imageGUI.h"
#include "../protocol/decoder/decoder.h"
#include "observerMap.h"

using namespace TerraMEObserver;

ObserverImage::ObserverImage (Subject *sub) : ObserverInterf(sub)
{
    obsImgGUI = new ImageGUI();

    observerType = TObsImage;
    subjectType = TObsUnknown;

    mapAttributes = new QHash<QString, Attributes*>();
    protocolDecoder = new Decoder(mapAttributes);

    painterWidget = new PainterWidget(mapAttributes);
    painterWidget->setOperatorMode(QPainter::CompositionMode_Multiply);
    // painterWidget->setGeometry(0, 0, 1500, 1500);
    // painterWidget->show();

    width = 0;
    height = 0;
    newWidthCellSpace = 0.;
    newHeightCellSpace = 0.;

    savingImages = true;
    builtLegend = 0;
    legendWindow = 0;		// ponteiro para LegendWindow
    path = DEFAULT_NAME;

    disableSaveImage = false;
}

ObserverImage::~ObserverImage()
{
    foreach(Attributes *attrib, mapAttributes->values())
        delete attrib;
    delete mapAttributes;

    delete painterWidget;
    delete legendWindow;

    delete obsImgGUI;
    delete protocolDecoder;
}

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
            decoded = protocolDecoder->decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
            if (decoded)
                painterWidget->plotMap(attrib);
        }
        qApp->processEvents();
    }

    if (/*decoded &&*/ legendWindow && (builtLegend < 2))
    {
        legendWindow->makeLegend();

        // Verificar porque a primeira invoca??o do m?todo plotMap
        // gera a imagem foreground totalmente preta. Assim, ? preciso
        // repetir essa chamada aqui!
        painterWidget->replotMap();

        builtLegend++;
    }

    //if (! disableSaveImage)
    //    return save();

    return decoded;
}

QStringList ObserverImage::getAttributes()
{
    return attribList;
}

const TypesOfObservers ObserverImage::getType()
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
}

void ObserverImage::setAttributes(QStringList &attribs, QStringList legKeys,
                                  QStringList legAttribs)
{
    // lista com os atributos que ser?o observados
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

    for (int j = 0; (legKeys.size() > 0 && j < LEGEND_KEYS.size()); j++)
    {
        if (legKeys.indexOf(LEGEND_KEYS.at(j)) < 0)
        {
            //qFatal("Error: Parameter legend \"%s\" not found. Please check it in the model.", qPrintable( LEGEND_KEYS.at(j) ) );
            //string err_out = string("Neighborhood '" ) + string (index) + string("' not found");
            lua_getglobal(L, "incompatibleTypesError");
            lua_pushstring(L,LEGEND_KEYS.at(j).toLatin1().constData());
            lua_pushstring(L,"string");
            lua_pushstring(L,"nil");
            lua_pushnumber(L,3);
            lua_call(L,4,0);
        }
    }
    int type = 0, mode = 0, slices = 0, precision = 0, stdDeviation = 0, max = 0;
    int min = 0, colorBar = 0, font = 0, fontSize = 0, symbol = 0, width = 0;

    Attributes *attrib = 0;
    for( int i = 0; i < attribList.size(); i++)
    {
        if ((! mapAttributes->contains(attribList.at(i)) )
                && (attribList.at(i) != "x") && (attribList.at(i) != "y") )
        {
            obsAttrib.append(attribList.at(i));
            attrib = new Attributes(attribList.at(i), width * height, newWidthCellSpace, newHeightCellSpace );
            attrib->setVisible(true);

            //------- Recupera a legenda do arquivo e cria o objeto attrib
            if (! legKeys.isEmpty())
            {
                type = legKeys.indexOf(TYPE);
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

                attrib->setDataType( (TypesOfData) legAttribs.at(type).toInt());
                attrib->setGroupMode( (GroupingMode) legAttribs.at(mode).toInt());
                attrib->setSlices(legAttribs.at(slices).toInt() - 1);				// conta com o zero
                attrib->setPrecisionNumber(legAttribs.at(precision).toInt() - 1);	// conta com o zero
                attrib->setStdDeviation( (StdDev) legAttribs.at(stdDeviation).toInt());
                attrib->setMaxValue(legAttribs.at(max).toDouble());
                attrib->setMinValue(legAttribs.at(min).toDouble());

                //Fonte
                attrib->setFontFamily(legAttribs.at(font));
                attrib->setFontSize(legAttribs.at(fontSize).toInt());

                //Converte o c?digo ASCII do s?mbolo em caracter
                bool ok = false;
                int asciiCode = legAttribs.at(symbol).toInt(&ok, 10);
                if (ok)
                    attrib->setSymbol( QString( QChar(asciiCode ) ));
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
            }

            mapAttributes->insert(attribList.at(i), attrib);
            attrib->makeBkp();
        }
    }

    if (! legendWindow)
        legendWindow = new LegendWindow();
    legendWindow->setValues(mapAttributes);   
}

void ObserverImage::setCellSpaceSize(int w, int h)
{
    width = w;
    height = h;
    newWidthCellSpace = width * SIZE_CELL;
    newHeightCellSpace = height * SIZE_CELL;

    painterWidget->resizeImage(QSize(newWidthCellSpace, newHeightCellSpace));
    needResizeImage = true;
}

bool ObserverImage::save()
{
    if (savingImages)
        savingImages = painterWidget->save(path);

    if (! savingImages)
    {
        obsImgGUI->setStatusMessage("Unable to save the image.");
        if (execModes != Quiet )
        {
            qWarning("Warning: Unable to save the image."
                     "The path is incorrect or you do not have permission to perform this task.");
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

const QSize ObserverImage::getCellSpaceSize()
{
    return QSize(newWidthCellSpace, newHeightCellSpace);
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
