#include "observerShapefile.h"
#include "decoder.h"
#include "canvas.h"

#include <QGraphicsScene>
#include<QDebug>

#include<vector>
#include<list>
#include<iostream>

using namespace TerraMEObserver;
using namespace std;

ObserverShapefile::ObserverShapefile(Subject *subj, QWidget *parent) :
    ObserverMapSuperclass(subj,TObsShapefile, QString("TerraME Observer : Shapefile"), parent)
{
}

ObserverShapefile::~ObserverShapefile()
{
    if(painter) delete painter;
    if(nshapes)
        for(int i = 0; i < nshapes; i++) delete shapes[i];
    if(pf)delete pf;
    if(ids) delete ids;
}

bool ObserverShapefile::draw(QDataStream &state)
{
    bool decoded = false;
    QString msg;
    state >> msg;

    QStringList tokens = msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);

    int j = 0;

    // int qtdParametros = tokens.at(2).toInt();
    
    QVector<double> xs, ys;

    // protocolDecoder->decode(msg, xs,ys);
    
    QList<Attributes *> listAttribs = mapAttributes->values();

    Attributes * attrib = 0;

    if(!ids){
        ids = new QVector<int>(nshapes);
        for(int i = 0; i < nshapes; i++){
            for(; j < tokens.size(); j++){
                if(tokens.at(j) == "objectId_"){
                    j+=2;
                    ids->insert(i,tokens.at(j).toInt());
                    break;
                }
            }
        }
        painter = new PainterShapefile(&shapes, *ids, shapeType, mapAttributes);
    }

    connectTreeLayerSlot(false);
    for (int i = 0; i < listAttribs.size(); i++)
    {
        attrib = listAttribs.at(i);
        if (attrib->getType() == TObsCell)
        {
            attrib->clear();
            qWarning() << "nao decodificou!!!!";
            // decoded = protocolDecoder->decode(msg, xs, ys);
            //qDebug()<<msg;
            painter->plotMap(attrib);
        }
        qApp->processEvents();
    }

    connectTreeLayerSlot(true);

    if((legendWindow) && (buildLegend < mapAttributes->size()))
    {
        connectTreeLayerSlot(false);
        legendWindow->makeLegend();
        showLayerLegend();

        painter->replotMap();
        connectTreeLayerSlot(true);

        // exibe o zoom de janela
        zoomWindow();
        buildLegend++;
    }

    //scene->update();
    //QWidget::update();

    //QImage image(scene->sceneRect().size().toSize(), QImage::Format_ARGB32);
    //image.fill(Qt::transparent);
    //QPainter painter(&image);
    //scene->render(&painter);
    //image.save("file_name.png");


    return decoded;
}



void ObserverShapefile::showLayerLegend()
{
    int layer = treeLayers->topLevelItemCount();

    QTreeWidgetItem *parent = 0, *child = 0;
    Attributes *attrib = 0;
    QVector<ObsLegend> *leg = 0;
    for(int i = 0; i < layer; i++)
    {
        parent = treeLayers->topLevelItem(i);
        treeLayers->setItemExpanded(parent, true);
        attrib = mapAttributes->value(parent->text(0));

        leg = attrib->getLegend();

        if (parent->childCount() > 0)
            parent->takeChildren();

        for(int j = 0; j < leg->size(); j++)
        {
            child = new QTreeWidgetItem( parent);
            child->setSizeHint(0, ICON_SIZE);
            child->setText(0, leg->at(j).getLabel());
            QColor color = leg->at(j).getColor();

            if (! leg->at(j).getLabel().contains("mean"))
                child->setData(0, Qt::DecorationRole,
                legendWindow->color2Pixmap(color, ICON_SIZE));
            else
                child->setData(0, Qt::DecorationRole, QString(""));
        }
    }
    painter->replotMap();
    QWidget::update();
    scene->update();
    treeLayers->resizeColumnToContents(0);
}


void ObserverShapefile::loadShape(const string &filename)
{
    SHPHandle hSHP = SHPOpen(filename.c_str(),"r");
    //cout<<(char*)filename.constData()<<endl;
    //qDebug()<<hSHP;
    int n;
    double minBound[4], maxBound[4];
    SHPGetInfo(hSHP, &n, &shapeType, minBound, maxBound);
    double w = fabs(maxBound[0] - minBound[0]);
    double h = fabs(maxBound[1] - minBound[1]);
    
    double sx = scene->sceneRect().width()/w;
    double sy = scene->sceneRect().height()/h;

    double s = max(sx,sy);

    double dx = minBound[0]*-1;
    double dy = minBound[1]*-1;

    scene->setSceneRect(scene->sceneRect().x(),scene->sceneRect().y(),w*s, h*s);

    nshapes = n;

    //QPointF center = scene->sceneRect().center();

    ids = NULL;

    pf = NULL;
    shapes.resize(nshapes);
    for(int i = 0; i < nshapes; i++)
    {
        SHPObject *obj = SHPReadObject(hSHP, i);
        //QGraphicsItem *item = createItem(obj,center.x(), center.y(),dx, dy);
        QGraphicsPathItem *item = createItem(obj,0, 0,dx, dy,s,s);
        shapes[obj->nShapeId] = item;
        scene->addItem(item);
        SHPDestroyObject(obj);
    }

    scaleView(1);
    //zoomWindow();

}

QGraphicsPathItem* ObserverShapefile::createItem(SHPObject *obj, int x, int y,double dx, double dy, double sx, double sy)
{
    switch(shapeType){
        case SHPT_POLYGONZ:
        case SHPT_POLYGON: 
            return createItemPolygon(obj,x,y,dx,dy,sx,sy);// polygon
        case SHPT_ARC:
        case SHPT_ARCZ:{
            return createItemPolyline(obj,x,y,dx,dy,sx,sy);//polyline
        }
        case SHPT_POINT:
        case SHPT_POINTZ:
            return createItemPoint(obj,x,y,dx,dy,sx,sy);//points
        default :
            return createItemPoint(obj,x,y,dx,dy,sx,sy);//default
    }
}

QGraphicsPathItem* ObserverShapefile::createItemPolygon(SHPObject *obj, int x, int y,double dx, double dy, double sx,double sy)
{
    QGraphicsPathItem *item = new QGraphicsPathItem;
    item->setPos(x,y);

    vector<list<QPointF> > points(obj->nParts);

    QPainterPath path;

    int j = 0;
    int i = 0;
    while(j < obj->nVertices && i < obj->nParts){
        i++;
        while(j < obj->panPartStart[i] || (obj->nParts  == 1 && j < obj->nVertices)){
            points[i-1].push_back(QPointF((obj->padfX[j]+dx),(obj->padfY[j]+dy)));
            j++;
        }
    }

    for(unsigned int i = 0; i < points.size(); i++){
        QPolygonF polygon;
        list<QPointF>::iterator it;
        for(it = points[i].begin(); it != points[i].end(); it++){
            polygon << *it;
        }
        path.addPolygon(polygon);
    }

    item->setPath(path);
    item->scale(sx, sy);
    return item;
}

QGraphicsPathItem* ObserverShapefile::createItemPoint(SHPObject *obj, int x, int y,double dx, double dy, double sx, double sy)
{
    QGraphicsPathItem *item = new QGraphicsPathItem;
    item->setPos(x,y);
    
    //qDebug()<<x<<", "<<y;
    
    QPainterPath path;
    for(int i = 0; i < obj->nVertices; i++)
        path.addRoundRect(obj->padfX[i]+dx,obj->padfY[i]+dy,1,1,90);

    item->setPath(path);
    item->setBrush(Qt::black);
    item->scale(sx, sy);

    return item;
}
QGraphicsPathItem* ObserverShapefile::createItemPolyline(SHPObject *obj, int x, int y,double dx, double dy, double sx, double sy)
{
    QGraphicsPathItem *item = new QGraphicsPathItem;
    item->setPos(x,y);
    
    vector<list<QPointF> > points(obj->nParts);

    int iPart,j=0,nextStart=0; 
	for (iPart = 0; iPart < obj->nParts; iPart++)
	{
		if (iPart == obj->nParts-1)
			nextStart = obj->nVertices;
		else 
			nextStart = obj->panPartStart[iPart+1];

		list<QPointF> line;
		while (j<nextStart)
		{
			line.push_back(QPointF(obj->padfX[j]+dx, obj->padfY[j]+dy));
			j++;
		}
		points[iPart] = line;
	}
    
    QPainterPath path;
    
    for(unsigned int i = 0; i < points.size(); i++){
        list<QPointF>::iterator it;
        it = points[i].begin();
        path = QPainterPath(*it);
        it++;
        for(; it != points[i].end(); it++){
            path.lineTo(*it);
        }
    }
    item->setBrush(Qt::NoBrush);

    item->setPath(path);
    item->scale(sx, sy);

    return item;
}

void ObserverShapefile::scaleView(qreal newScale)
{
    QMatrix oldMatrix = view->matrix();
    view->resetMatrix();
    view->translate(oldMatrix.dx(), oldMatrix.dy());
    view->scale(newScale, newScale*-1);
}

void ObserverShapefile::treeLayers_itemChanged(QTreeWidgetItem * item, int /*column*/)
{
    if (obsAttrib.size() == 0)
        return;

    Attributes * attrib = mapAttributes->value(item->text(0));
    if (attrib)
    {
        attrib->setVisible( (item->checkState(0) == Qt::Checked) ? true : false );
        painter->replotMap();
    }
}

int ObserverShapefile::close()
{
    ObserverMapSuperclass::close();
    return 0;
}


