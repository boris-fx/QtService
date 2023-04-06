#ifndef QTSERVICE_GLOBAL_H
#define QTSERVICE_GLOBAL_H

#include <QtCore/qglobal.h>

#ifndef QT_STATIC
#  if defined(QT_BUILD_SERVICE_LIB)
#    define Q_SERVICE_EXPORT Q_DECL_EXPORT
#  else
#    define Q_SERVICE_EXPORT Q_DECL_IMPORT
#  endif
#else
#  define Q_SERVICE_EXPORT
#endif

#define Q_T QStringLiteral  // for mere brevity; name is inspired by Windows' _T

#endif // QTSERVICE_GLOBAL_H
